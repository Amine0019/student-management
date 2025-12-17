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
                sh 'sudo docker build -t chirinedardouri/alpine:1.0.0 .'
            }
        }

        stage('Push Docker Image') {
          steps {
        withCredentials([usernamePassword(
            credentialsId: 'mydockerhub-credentials', 
            usernameVariable: 'DOCKER_USER', 
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh 'echo $DOCKER_PASS | sudo docker login -u $DOCKER_USER --password-stdin'
            sh 'sudo docker push chirinedardouri/alpine:1.0.0'
        }
    }
}

        stage('Deploy') {
            steps {
                sh '''
                    sudo docker stop studentapp || true
                    sudo docker rm studentapp || true
                    sudo docker run -d --name studentapp -p 8081:8080 chirinedardouri/alpine:1.0.0
                '''
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                set -xe

                echo "Checking cluster access..."
                kubectl --kubeconfig=/home/vagrant/.kube/config get nodes

                echo "Deploying MySQL..."
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -f k8s/mysql-pv.yaml
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -f k8s/mysql-pvc.yaml
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -f k8s/mysql-deployment.yaml
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -f k8s/mysql-service.yaml

                echo "Deploying Spring Boot..."
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -n student-app -f k8s/spring-config-secret.yaml
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -n student-app -f k8s/spring-deployment.yaml
                kubectl --kubeconfig=/home/vagrant/.kube/config apply -n student-app -f k8s/spring-service.yaml

                echo "Waiting for rollouts..."
                kubectl --kubeconfig=/home/vagrant/.kube/config rollout status deployment/mysql -n student-app
                kubectl --kubeconfig=/home/vagrant/.kube/config rollout status deployment/spring-boot -n student-app
                '''
            }
        }
    }

}