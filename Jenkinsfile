pipeline {
    agent any

    environment {
        IMAGE_NAME = "mouadboulatar/flask-stock-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKERHUB_CRED = 'dockerhub-creds'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                sh 'python3 --version'
                sh 'docker --version'
                sh 'kubectl version --client'
                sh 'git --version'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip3 install -r requirements.txt'
            }
        }

        stage('Test Application') {
            steps {
                sh 'python3 -m py_compile app/app.py'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CRED,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker push $IMAGE_NAME:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl set image deployment/flask-stock-app \
                        flask-stock-app=${IMAGE_NAME}:${IMAGE_TAG} --record
                    kubectl rollout status deployment/flask-stock-app
                """
            }
        }
    }

    post {
        always {
            sh 'kubectl get pods'
            sh 'kubectl get svc'
            sh 'docker system prune -f || true'
        }
        success {
            echo "✅ Déploiement réussi ! Image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }
        failure {
            echo '❌ Échec du pipeline'
            sh 'kubectl describe pods'
        }
    }
}