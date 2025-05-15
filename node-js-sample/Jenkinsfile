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

 
    }
} 