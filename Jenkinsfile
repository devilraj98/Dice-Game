pipeline {
    agent any

    parameters {
        choice(
            name: 'ENV',
            choices: ['dev', 'stage', 'prod'],
            description: 'Deployment environment'
        )
        string(
            name: 'IMAGE_TAG',
            defaultValue: 'v1',
            description: 'Docker image tag'
        )
    }

    environment {
        DOCKER_IMAGE = "neeraj98/dice-game"
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
                  docker build -t ${DOCKER_IMAGE}:${params.IMAGE_TAG} .
                """
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_TOKEN')]) {
                    sh """
                    echo $DOCKER_TOKEN | docker login -u your-dockerhub-username --password-stdin
                    docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                 expression { params.ENV != 'prod' }
              }
              steps {
                   sh """
                   helm upgrade --install dice-game helm/dice-game \
                   --set image.repository=${DOCKER_IMAGE} \
                   --set image.tag=${IMAGE_TAG}
                   """
                }
        }
        stage('Production Approval') {
            when {
                 expression { params.ENV == 'prod' }
                 }
                 steps {
                     input message: "Approve production deployment?"
                 }
        }
        stage('Deploy to Production') {
            when {
                expression { params.ENV == 'prod' }
            }
            steps {
                sh """
                helm upgrade --install dice-game helm/dice-game \
                --set image.repository=${DOCKER_IMAGE} \
                --set image.tag=${IMAGE_TAG}
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
