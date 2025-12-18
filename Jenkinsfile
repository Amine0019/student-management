pipeline {
    agent any
    
    environment {
        SONAR_HOST_URL = 'http://172.25.125.3:9000'
        MAVEN_HOME = '/usr/share/maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
    }
    
    stages {
        stage('1. GIT Checkout') {
            steps {
                echo 'Checking out code from Git...'
                git branch: 'zouaoui-samer', 
                    url: 'https://github.com/Amine0019/student-management.git', 
                    credentialsId: '3c513d29-97f9-4563-a82a-738fa9ed3009'
            }
        }
        
        stage('2. Maven Build') {
            steps {
                echo 'Building with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('3. SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonarqube') {
                        echo 'Running SonarQube analysis...'
                        withCredentials([string(credentialsId: 'jenkins-sonar', variable: 'SONAR_TOKEN')]) {
                            sh '''
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=student-management \
                                  -Dsonar.projectName="Student Management" \
                                  -Dsonar.login=${SONAR_TOKEN}
                            '''
                        }
                    }
                }
            }
        }
        
        stage('4. Quality Gate') {
            steps {
                script {
                    echo 'Waiting for Quality Gate...'
                    timeout(time: 5, unit: 'MINUTES') {
                        // Spécifiez explicitement l'URL du serveur SonarQube
                        def qg = waitForQualityGate(abortPipeline: true, credentialsId: 'jenkins-sonar')
                        if (qg.status != 'OK') {
                            error "Quality Gate failed: ${qg.status}"
                        } else {
                            echo 'Quality Gate passed!'
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            echo "View results: ${SONAR_HOST_URL}/dashboard?id=student-management"
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
