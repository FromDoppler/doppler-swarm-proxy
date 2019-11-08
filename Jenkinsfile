pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''docker build  \\
                    -t "fromdoppler/sites-proxy:production-commit-${GIT_COMMIT}" \\
                    ./sites-proxy'''
            }
        }
        stage('Publish pre release version images') {
            // It is a temporal step, in the future we will only publish final version images
            steps {
                sh 'sh ./publish-commit-image-to-dockerhub.sh production ${GIT_COMMIT} v0.0.0 commit-${GIT_COMMIT}'
            }
        }
    }
}
