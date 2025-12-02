pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'refs/heads/chirinedardouri']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/Amine0019/student-management.git',
                        credentialsId: 'mycredentials'
                    ]]
                ])
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                echo 'mvn test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t chirinedardouri/alpine:1.0.0 .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'mydockerhub-credentials'
                )]) {
                    sh 'docker push chirinedardouri/alpine:1.0.0'
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker stop studentapp || true
                    docker rm studentapp || true
                    docker run -d --name studentapp -p 8081:8080 chirinedardouri/alpine:1.0.0
                '''
            }
        }
    }
}
