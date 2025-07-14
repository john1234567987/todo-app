pipeline {
    agent any
    tools {
        terraform 'terraform' // Match the name from your Jenkins tool config
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
                        terraform init -backend-config=backend-dev.hcl
                        terraform plan -out=tfplan
                    '''
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
