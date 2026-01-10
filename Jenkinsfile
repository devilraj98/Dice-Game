pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "neeraj98/dice-game"
        DOCKER_TAG   = "${BUILD_NUMBER}"
        HELM_RELEASE = "dice-game"
        K8S_NAMESPACE = "default"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/devilraj98/Dice-Game.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                """
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh """
                  helm upgrade --install ${HELM_RELEASE} helm/dice-game \
                    --namespace ${K8S_NAMESPACE} \
                    --set image.repository=${DOCKER_IMAGE} \
                    --set image.tag=${DOCKER_TAG}
                """
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully"
        }
        failure {
            echo "Pipeline failed"
        }
    }
    
}
