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
        stage('Install kubectl') {
            steps {
                sh '''
                if [ ! -f kubectl ]; then
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                else
                    echo "kubectl already exists"
                fi
                ./kubectl version --client
                '''
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                    export BUILD_NUMBER=${BUILD_NUMBER}
                    envsubst < deployment.yaml.template > deployment.yaml
                    ./kubectl --kubeconfig=$KUBECONFIG_FILE apply -f deployment.yaml
                    ./kubectl --kubeconfig=$KUBECONFIG_FILE rollout status deployment/myapp-deployment
                    ./kubectl --kubeconfig=$KUBECONFIG_FILE get pods
                    '''
                }
            }
        }
    }
}

 
