pipeline {
    agent {
        docker {
            image 'node:18-alpine'
            args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
        }
    }

    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'yourdockerhubusername/myapp' // 🔁 Replace with your DockerHub username
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE = "${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
        KUBECONFIG = '/var/jenkins_home/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Tools') {
            steps {
                sh '''
                apk add --no-cache curl bash git docker-cli

                # Install kubectl
                curl -LO "https://dl.k8s.io/release/stable.txt"
                KUBECTL_VERSION=$(cat stable.txt)
                curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                chmod +x kubectl && mv kubectl /usr/local/bin/
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
                echo "Running tests..."
                sh '''
                docker run --rm ${DOCKER_IMAGE} npm test
                '''
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
                sh '''
                cat <<EOF | kubectl apply -f -
                apiVersion: apps/v1
                kind: Deployment
                metadata:
                  name: myapp-deployment
                  labels:
                    app: myapp
                spec:
                  replicas: 1
                  selector:
                    matchLabels:
                      app: myapp
                  template:
                    metadata:
                      labels:
                        app: myapp
                    spec:
                      containers:
                      - name: myapp
                        image: ${DOCKER_IMAGE}
                        ports:
                        - containerPort: 5000
                ---
                apiVersion: v1
                kind: Service
                metadata:
                  name: myapp-service
                spec:
                  selector:
                    app: myapp
                  ports:
                  - port: 80
                    targetPort: 5000
                  type: NodePort
                EOF

                kubectl rollout status deployment/myapp-deployment
                minikube service myapp-service --url || true
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 CI/CD Pipeline completed successfully!'
            slackSend (
                color: '#36a64f',
                message: "✅ Build #${BUILD_NUMBER} of *${JOB_NAME}* succeeded! 🎉\n${BUILD_URL}"
            )
        }

        failure {
            echo '💥 CI/CD Pipeline failed!'
            slackSend (
                color: '#ff0000',
                message: "❌ Build #${BUILD_NUMBER} of *${JOB_NAME}* failed! 💥\n${BUILD_URL}"
            )
        }

        always {
            echo 'Cleaning up Docker image...'
            sh 'docker rmi ${DOCKER_IMAGE} || echo "Image not found or already removed"'
        }
    }
}
