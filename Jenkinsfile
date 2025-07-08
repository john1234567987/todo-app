pipeline {
    agent any  // this means any available Jenkins agent can run this job

    tools {
        maven 'Maven 3.9.10' // replace with the Maven tool name you configured in Jenkins global tools
    }

    stages {
        stage('Checkout') {
            steps {
                // Pull the code from source control
                checkout scm
            }
        }

        stage('Build') {
            steps {
                // Run a Maven build
                sh 'mvn clean install'
            }
        }

        stage('Test') {
            steps {
                // Run Maven tests
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                // Package the application (if applicable)
                sh 'mvn package'
            }
        }
    }

    post {
        always {
            // Clean up workspace after build
            cleanWs()
        }
    }
}
