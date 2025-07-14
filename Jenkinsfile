pipeline {
    agent any
    tools {
        terraform 'terraform' // Match the name from your Jenkins tool config
    }
    parameters {
        string(name: 'BACKEND_CONFIG_FILE', defaultValue: 'backend-dev.hcl', description: 'Terraform backend config file')
    }
    stages {
        stage('Terraform Init & Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'todo-app-aws-credential']]) {
                    sh '''
                        set -e
                        git --version
                        pwd
                        ls -la
                        cd root
                        pwd
                        ls -la
                        terraform init -backend-config=${BACKEND_CONFIG_FILE}
                        terraform plan -out=tfplan
                    '''
                }
            }
        }
            
     stage('Terraform Apply') {
              steps {
                script {
                  input message: "Approve apply?"
                  sh 'terraform apply "tfplan"'
                }
              }
            }


        stage('Terraform Destroy') {
            steps {
                input message: 'Confirm destroy?', ok: 'Destroy'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'todo-app-aws-credential']]) {
                    sh '''
                        cd root/
                        terraform destroy -auto-approve
                    '''
                }
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}
