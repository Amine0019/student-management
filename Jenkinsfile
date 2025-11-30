pipeline {
	agent any
	tools {
		maven 'M2_HOME'
	}
	stages {
		stage('Hello') {
			steps {
				echo 'Hello World'
			}
		}
		stage('GIT'){
			steps{
				git branch : 'Amine-Larbi',
				url : 'https://github.com/Amine0019/student-management.git'
			}
		}
		stage('MAVEN'){
			steps{
				sh "mvn -version"
			}
		}

	}
}