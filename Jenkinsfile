pipeline {
    agent any

    stages {

        stage('1 git') {
            steps {
                git branch: 'ilyes-branch', url: 'https://github.com/Amine0019/student-management.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test with Docker') {
            steps {
                script {
                    docker.image('maven:3.9.6-eclipse-temurin-17').inside {
                        sh 'mvn test'
                    }
                }
            }
        }

    }
}
