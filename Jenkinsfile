pipeline {
    agent any

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
            terraform init
            terraform plan -out=tfplan
        '''

        }
    }
}


        stage('Terraform Apply') {
            steps {
                input message: 'Approve apply?', ok: 'Apply'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'todo-app-aws-credential']]) {
                    sh '''
                        cd todo-app/terraform
                        terraform apply tfplan
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
