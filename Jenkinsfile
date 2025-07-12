pipeline {
    agent any

   stages {
        stage('Clone Repo') {
            steps {
                sshagent (credentials: ['github-todo-app']) {
                    sh 'git clone git@github.com:john1234567987/todo-app.git'
                }
            }
        }


stage('Terraform Init & Plan') {
    steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'todo-app-aws-credential']]) {
        sh '''
            set -e
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
