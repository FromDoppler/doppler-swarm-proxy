pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build ./sites-proxy'
            }
        }
        stage('Deploy build image') {
            steps {
                sh 'sh ./publish-to-dockerhub.sh build-$BUILD_NUMBER'
            }
        }
        stage('Deploy for production') {
            when {
                branch 'master'
            }
            steps {
                sh 'sh ./publish-to-dockerhub.sh beta'
            }
        }
    }
}
