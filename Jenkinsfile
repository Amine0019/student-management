pipeline {
    agent any

    environment {
        SONAR_HOST_URL = 'http://172.25.125.3:9000'
        MAVEN_HOME = '/usr/share/maven'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
        DOCKER_IMAGE = 'student-management'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE = 'default'
    }

    stages {
        // SUPPRIMEZ LE STAGE "1. GIT Checkout" - Jenkins le fait déjà automatiquement

        stage('2. Maven Build') {
            steps {
                echo '🔨 Building with Maven...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('3. SonarQube Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonarqube') {
                        echo '🔍 Running SonarQube analysis...'
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
                    echo '⏳ Waiting for Quality Gate...'
                    timeout(time: 10, unit: 'MINUTES') {
                        try {
                            sleep(time: 10, unit: 'SECONDS')
                            def qg = waitForQualityGate(abortPipeline: false)
                            if (qg.status != 'OK') {
                                echo "⚠️ Quality Gate: ${qg.status}"
                                currentBuild.result = 'UNSTABLE'
                            } else {
                                echo '✅ Quality Gate passed!'
                            }
                        } catch (Exception e) {
                            echo "⚠️ Quality Gate: ${e.message}"
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
                }
            }
        }

        stage('5. Docker Build') {
            steps {
                script {
                    echo '🐳 Building Docker image...'

                    sh '''
                        # Build avec Docker
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                        docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest

                        # Sauvegarder l'image
                        docker save ${DOCKER_IMAGE}:${DOCKER_TAG} -o /tmp/${DOCKER_IMAGE}-${DOCKER_TAG}.tar

                        # Importer dans containerd pour Kubernetes
                        sudo ctr -n k8s.io images import /tmp/${DOCKER_IMAGE}-${DOCKER_TAG}.tar

                        # Tag latest aussi dans containerd
                        docker save ${DOCKER_IMAGE}:latest -o /tmp/${DOCKER_IMAGE}-latest.tar
                        sudo ctr -n k8s.io images import /tmp/${DOCKER_IMAGE}-latest.tar

                        # Nettoyer
                        rm /tmp/${DOCKER_IMAGE}-*.tar

                        # Vérifier
                        sudo crictl images | grep ${DOCKER_IMAGE} || echo "Image imported"
                    '''

                    echo "✅ Image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('6. Deploy to Kubernetes') {
            steps {
                script {
                    echo '☸️  Deploying to Kubernetes...'

                    sh """
                        # Vérifier que les fichiers k8s existent
                        echo "=== Checking k8s files ==="
                        ls -la k8s/

                        # Vérifier connexion
                        kubectl version --client
                        kubectl cluster-info

                        # Appliquer manifests
                        kubectl apply -f k8s/deployment.yaml -n ${K8S_NAMESPACE}
                        kubectl apply -f k8s/service.yaml -n ${K8S_NAMESPACE}

                        # Mettre à jour l'image
                        kubectl set image deployment/student-management \
                          student-management=${DOCKER_IMAGE}:${DOCKER_TAG} \
                          -n ${K8S_NAMESPACE}

                        # Forcer un redémarrage pour prendre la nouvelle image
                        kubectl rollout restart deployment/student-management -n ${K8S_NAMESPACE}

                        # Attendre rollout
                        kubectl rollout status deployment/student-management \
                          -n ${K8S_NAMESPACE} --timeout=5m
                    """

                    echo '✅ Deployment successful!'
                }
            }
        }

        stage('7. Verify Deployment') {
            steps {
                script {
                    echo '🔍 Verifying deployment...'

                    sh """
                        echo "=== Pods Status ==="
                        kubectl get pods -n ${K8S_NAMESPACE} -l app=student-management -o wide

                        echo "=== Service Info ==="
                        kubectl get svc -n ${K8S_NAMESPACE} student-management-service

                        echo "=== Deployment Info ==="
                        kubectl get deployment -n ${K8S_NAMESPACE} student-management

                        echo "=== Application URL ==="
                        NODE_IP=\$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
                        echo "Application accessible at: http://\${NODE_IP}:30080"
                    """
                }
            }
        }
    }

    post {
        always {
            echo "📊 SonarQube: ${SONAR_HOST_URL}/dashboard?id=student-management"
            script {
                sh '''
                    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
                    echo "☸️  Kubernetes Dashboard: kubectl get all -n ${K8S_NAMESPACE}"
                    echo "🌐 Application URL: http://${NODE_IP}:30080"
                '''
            }
        }
        success {
            echo '✅ Pipeline completed successfully!'
        }
        unstable {
            echo '⚠️ Pipeline completed with warnings'
        }
        failure {
            echo '❌ Pipeline failed!'
            script {
                try {
                    sh "kubectl rollout undo deployment/student-management -n ${K8S_NAMESPACE}"
                    echo '↩️  Rolled back to previous version'
                } catch (Exception e) {
                    echo "Could not rollback: ${e.message}"
                }
            }
        }
    }
}