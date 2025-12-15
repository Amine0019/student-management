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


		stage('Build Docker Image') {
			steps {
				sh 'docker build -t amine0019/student-management-backend:latest .'
			}
		}

		stage('Push Docker Image') {
			steps {
				withCredentials([usernamePassword(
					credentialsId: 'dockerhub-credentials',
					usernameVariable: 'DOCKER_USER',
					passwordVariable: 'DOCKER_PSW'
				)]) {
					sh 'echo $DOCKER_PSW | docker login -u $DOCKER_USER --password-stdin'
					sh 'docker push amine0019/student-management-backend:latest'
				}
			}
		}

		stage('Deploy to Kubernetes') {
			steps {
				withCredentials([file(credentialsId: 'kubeconfig-devops', variable: 'KUBECONFIG')]) {
					sh '''
              export KUBECONFIG=$KUBECONFIG
              kubectl get nodes
              kubectl apply -n devops -f k8s/mysql-pv-pvc.yaml
              kubectl apply -n devops -f k8s/mysql-deployment.yaml
              kubectl apply -n devops -f k8s/spring-deployment.yaml
            '''
				}
			}
		}





	}
}