pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build ./sites-proxy'
            }
        }
        stage('Publish pre release version images') {
            steps {
                sh 'sh ./sites-proxy/build-n-publish.sh production ${GIT_COMMIT} v0.0.0 commit-${GIT_COMMIT}'
            }
        }
        stage('Publish final version images') {
            when {
                expression {
                    return isVersionTag(readCurrentTag())
                }
            }
            steps {
                sh 'sh ./sites-proxy/build-n-publish.sh production ${GIT_COMMIT} ${TAG_NAME}'
            }
        }
        stage('Generate version') {
            when {
                branch 'master'
            }
            steps {
                sh 'TODO: generate a tag automatically'
            }
        }
    }
}


def boolean isVersionTag(String tag) {
    echo "checking version tag $tag"

    if (tag == null) {
        return false
    }

    // use your preferred pattern
    def tagMatcher = tag =~ /v\d+\.\d+\.\d+/

    return tagMatcher.matches()
}

// https://stackoverflow.com/questions/56030364/buildingtag-always-returns-false
// workaround https://issues.jenkins-ci.org/browse/JENKINS-55987
def String readCurrentTag() {
    return sh(returnStdout: true, script: "git describe --tags --match v?*.?*.?* --abbrev=0 --exact-match || echo ''").trim()
}

