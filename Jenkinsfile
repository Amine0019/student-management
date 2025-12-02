pipeline {
	agent any

	stages {
		stage('1 git') {
			steps {
				git branch: 'Amine-Larbi',
				url: 'https://github.com/Amine0019/student-management.git'
			}
		}
		stage('Build JAR') {
			steps {
				sh 'mvn clean package -DskipTests'
			}
		}
	}
}