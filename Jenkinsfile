pipeline {
    agent any

    environment {
        DOCKERHUB = credentials('dockerhub-creds')   // DockerHub creds in Jenkins
        AWS_CREDS = credentials('aws-creds')         // AWS IAM creds in Jenkins
        IMAGE_NAME = "dice-game"                     // name of your docker image
        REGION = "ap-south-1"                        // your AWS region
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/devilraj98/Dice-Game.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t $IMAGE_NAME .
                '''
            }
        }

        stage('DockerHub Login') {
            steps {
                sh '''
                    echo "Logging into DockerHub..."
                    echo $DOCKERHUB_PSW | docker login -u $DOCKERHUB_USR --password-stdin
                '''
            }
        }

        stage('Tag & Push Image') {
            steps {
                sh '''
                    echo "Tagging & pushing Docker image..."
                    docker tag $IMAGE_NAME $DOCKERHUB_USR/$IMAGE_NAME:latest
                    docker push $DOCKERHUB_USR/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Configure AWS CLI') {
            steps {
                sh '''
                    echo "Configuring AWS CLI..."
                    aws configure set aws_access_key_id $AWS_CREDS_USR
                    aws configure set aws_secret_access_key $AWS_CREDS_PSW
                    aws configure set default.region $REGION
                '''
            }
        }

        stage('Update Kubeconfig for Dev Cluster') {
            steps {
                sh '''
                    echo "Updating kubeconfig for Dev cluster..."
                    aws eks update-kubeconfig --name dev-eks --region $REGION
                '''
            }
        }

        stage('Deploy to Dev using Helm') {
            steps {
                sh '''
                    echo "Deploying to Dev namespace via Helm..."
                    helm upgrade --install dice-game-dev ./helm/dice-game \
                      --namespace dev --create-namespace \
                      --set image.repository=$DOCKERHUB_USR/$IMAGE_NAME \
                      --set image.tag=latest
                '''
            }
        }

        stage('Update Kubeconfig for Staging Cluster') {
            steps {
                sh '''
                    echo "Updating kubeconfig for Staging cluster..."
                    aws eks update-kubeconfig --name staging-eks --region $REGION
                '''
            }
        }

        stage('Deploy to Staging using Helm') {
            steps {
                sh '''
                    echo "Deploying to Staging namespace via Helm..."
                    helm upgrade --install dice-game-staging ./helm/dice-game \
                      --namespace staging --create-namespace \
                      --set image.repository=$DOCKERHUB_USR/$IMAGE_NAME \
                      --set image.tag=latest
                '''
            }
        }

        stage('Update Kubeconfig for Prod Cluster') {
            steps {
                sh '''
                    echo "Updating kubeconfig for Prod cluster..."
                    aws eks update-kubeconfig --name prod-eks --region $REGION
                '''
            }
        }

        stage('Deploy to Prod using Helm') {
            steps {
                sh '''
                    echo "Deploying to Prod namespace using Helm..."
                    helm upgrade --install dice-game-prod ./helm/dice-game \
                      --namespace prod --create-namespace \
                      --set image.repository=$DOCKERHUB_USR/$IMAGE_NAME \
                      --set image.tag=latest
                '''
            }
        }
    }
}
