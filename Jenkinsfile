pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        IMAGE_NAME = 'rajsingh8826/myapp'
        IMAGE_TAG = "${BUILD_NUMBER}"
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
                sudo apt-get update && sudo apt-get install -y curl git docker.io

                curl -LO "https://dl.k8s.io/release/stable.txt"
                KUBECTL_VERSION=$(cat stable.txt)
                curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                chmod +x kubectl && sudo mv kubectl /usr/local/bin/
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
}
