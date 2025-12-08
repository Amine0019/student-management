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
		stage('4 SonarQube analysis') {
			steps {
				withSonarQubeEnv('My SonarQube Server') {
					sh """
                mvn sonar:sonar \
                  -Dsonar.projectKey=tn.esprit:student-management \
                  -Dsonar.projectName=student-management \
                  -Dsonar.sources=src/main/java \
                  -Dsonar.tests=src/test/java \
                  -Dsonar.java.binaries=target/classes \
                  -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
            """
				}
			}
		}
		stage('Quality Gate Check') {
			steps {
				script {
					timeout(time: 15, unit: 'MINUTES') {
						def qg = waitForQualityGate()
						if (qg.status != 'OK') {
							error "Quality gate failed: ${qg.status}"
						}
						echo "✅ Quality gate passed: ${qg.status}"
					}
				}
			}
		}



	}
}