pipeline {
    agent any
    parameters {
        string(name: 'BACKEND_CONFIG_FILE', defaultValue: 'backend-dev.hcl', description: 'Terraform backend config file')
    }
    stages {
        stage('Build Terraform Docker Image') {
            steps {
                script {
                    docker.build('my-terraform-image:latest', '.')
                }
            }
        }

        stage('Terraform Init & Plan') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'todo-app-aws-credential']]) {
                    script {
                        docker.image('my-terraform-image:latest').inside {
                            sh '''
                                set -e
                                pwd
                                ls -la
                                cd root
                                terraform init -backend-config=${BACKEND_CONFIG_FILE}
                                terraform plan -out=tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    input message: "Approve apply?"
                    docker.image('my-terraform-image:latest').inside {
                        sh 'terraform apply "tfplan"'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                input message: 'Confirm destroy?', ok: 'Destroy'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'todo-app-aws-credential']]) {
                    docker.image('my-terraform-image:latest').inside {
                        sh '''
                            cd root
                            terraform destroy -auto-approve
                        '''
                    }
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
