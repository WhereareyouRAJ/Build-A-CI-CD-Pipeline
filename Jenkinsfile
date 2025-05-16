pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'rajsingh8826/myapp'
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        
    }
    stages {
        stage('Install Tools') {
            steps {
                sh '''
                 apt-get update
                
                '''
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run --rm ${DOCKER_IMAGE} npm test || true'
            }
        }
        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin
                    docker push ${DOCKER_IMAGE}
                    docker logout
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                    echo "apiVersion: apps/v1" > deployment.yaml
                    echo "kind: Deployment" >> deployment.yaml
                    echo "metadata:" >> deployment.yaml
                    echo "  name: myapp-deployment" >> deployment.yaml
                    echo "  labels:" >> deployment.yaml
                    echo "    app: myapp" >> deployment.yaml
                    echo "spec:" >> deployment.yaml
                    echo "  replicas: 5" >> deployment.yaml
                    echo "  selector:" >> deployment.yaml
                    echo "    matchLabels:" >> deployment.yaml
                    echo "      app: myapp" >> deployment.yaml
                    echo "  template:" >> deployment.yaml
                    echo "    metadata:" >> deployment.yaml
                    echo "      labels:" >> deployment.yaml
                    echo "        app: myapp" >> deployment.yaml
                    echo "    spec:" >> deployment.yaml
                    echo "      containers:" >> deployment.yaml
                    echo "      - name: myapp" >> deployment.yaml
                    echo "        image: rajsingh8826/myapp:15" >> deployment.yaml
                    echo "        ports:" >> deployment.yaml
                    echo "        - containerPort: 5000" >> deployment.yaml

                    ./kubectl --kubeconfig=$KUBECONFIG_FILE apply -f deployment.yaml
                    ./kubectl --kubeconfig=$KUBECONFIG_FILE rollout status deployment/myapp-deployment
                    '''
                }
            }
        }
    }
}

            post {
        success {
            echo '✅ CI/CD Pipeline completed successfully!'
        }
        failure {
            echo '❌ CI/CD Pipeline failed!'
        }
        always {
            echo '🧹 Cleaning up Docker image...'
            sh 'docker rmi ${DOCKER_IMAGE} || true'
        }
    }
