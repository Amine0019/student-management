pipeline {
	agent any
	tools {
		maven 'M2_HOME'
	}
	environment {
		SONAR_TOKEN = credentials('SONAR_LOGIN')
		SONAR_HOST_URL = 'http://172.18.3.161:9000'
	}
	stages {
		stage('1 git') {
			steps {
				git branch: 'Amine-Larbi',
				url: 'https://github.com/Amine0019/student-management.git'
			}
		}
		stage('2 MVN clean ') {
			steps {
				sh 'mvn clean  package -DskipTests'
			}
		}
		stage('3 MVN compile ') {
			steps {
				sh 'mvn compile  package -DskipTests'
			}
		}
		stage('4 SonarQube analysis'){
			steps {
				withSonarQubeEnv('My SonarQube Server') {
					sh 'mvn sonar:sonar'
				}
			}

		}
		stage('5 Quality Gate Check'){
			steps {
				timeout(time: 1, unit: 'HOURS') {
					waitForQualityGate abortPipeline: true
				}
			}
		}


	}
}