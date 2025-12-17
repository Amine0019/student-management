pipeline {
    agent any
    
    environment {
        SONAR_HOST_URL = 'http://localhost:9000'
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
                        echo ' Running SonarQube analysis...'
                        sh '''
                            mvn sonar:sonar \
                              -Dsonar.projectKey=student-management \
                              -Dsonar.projectName="Student Management" \
                              -Dsonar.host.url=${SONAR_HOST_URL}
                        '''
                    }
                }
            }
        }
        
        stage('4. Quality Gate') {
            steps {
                script {
                    echo ' Waiting for Quality Gate...'
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            echo " Quality Gate status: ${qg.status}"
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
            echo ' Pipeline completed successfully!'
            echo " View results: ${SONAR_HOST_URL}/dashboard?id=student-management"
        }
        failure {
            echo ' Pipeline failed!'
        }
    }
}
