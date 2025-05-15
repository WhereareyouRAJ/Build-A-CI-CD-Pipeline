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
                 sh '''
                 curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                 chmod +x kubectl
                 mv kubectl /usr/local/bin/
                 kubectl version --client
                 '''
                 


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
                 script {
                        kubeconfig(caCertificate: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCakNDQWU2Z0F3SUJBZ0lCQVRBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwdGFXNXAKYTNWaVpVTkJNQjRYRFRJMU1EUXhNekExTkRjeE1Wb1hEVE0xTURReE1qQTFORGN4TVZvd0ZURVRNQkVHQTFVRQpBeE1LYldsdWFXdDFZbVZEUVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTVFOCnNVQWdnVU90WTlRa283N2phZERnZStBSXNLaUw4UEx2cGVleWVJOENyMEJzWjllQzRrMCtnZmdXais4bzc5QWkKUEhMYVZHR2t0dCtEY0ttUGM4bzNsNFIyYjFBQXQrcFZLcWE4VGlTU1U3RjF3a2kzRzRIUzlFMVNuQThuZTdXYwpZaTBUVTNpaTJ5NERiSE81KzlSOUtXdzVLRFp2QUZMVGt0MlY3VnZtU0IyU2ZMUzY1K0N3VGRGZWNxZXlTU3FxCnI3NmZIOFI3aFgvSjk1dWd6WENUVGl1ZUllTzZkRHFPSmtISlBjU1J0VkwzNS83TEcwQURLUWF0R2U3cG1UK3EKYzJmT1hDc1J0d3lTRWJpemw2T3huQWVxVXBPdnQwRGtnYUxocXFHUmF2cTVFWjBmSW1IY3NaODFZNnh6dkIyaQp0NVZuQ0VMSXZhZlRxcEk2ZGo4Q0F3RUFBYU5oTUY4d0RnWURWUjBQQVFIL0JBUURBZ0trTUIwR0ExVWRKUVFXCk1CUUdDQ3NHQVFVRkJ3TUNCZ2dyQmdFRkJRY0RBVEFQQmdOVkhSTUJBZjhFQlRBREFRSC9NQjBHQTFVZERnUVcKQkJTcE1ZSlNmdytrbjg1Z21ZemdnaXRKZktrL3ZEQU5CZ2txaGtpRzl3MEJBUXNGQUFPQ0FRRUFuVmZVQ3VJSApjazk5ZWhqSDA3UEIwTENucnBOelY0K0UzZlVhdElpV1pSKzhZeUJCc2RxcHZDT1hYa2RtN3pvU2V0R3gwbVFxCi9EUThKOEpidzlkMmpIcTRhMWRjSDhlWHU4WVFHeTV1MjdHUTd6TkdEbldGUFhTUjZic2p1K1Q1bkNGeFBOcSsKYVpCY1hGUFg4T3NoMWFhMWFKVU9UcDYxQjI3SzF6eG9QeTEwbWRXYTZEMkpNNHduc1dNcGNzaHdseDhmUExlSApTd2tYUjZ2NHNOaTVidHRqN0FFVEtWQWgybE0wcm9CVnVheGptUlFvZTFtMnZUbzNCMnI0bTZnaUFaeXRSV21PCkpuRWFlR3FiM1htUnJpeWxYR2hJUUIxNGpKd1ptNWJmNGZ2TWhKRkxWcXJENExNSkRBckN4WEpVOTI2bzBaa00KSG43MkZGdWJwc2k2dHc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==', serverUrl: 'https://127.0.0.1:59504') {
                   sh 'kubectl apply -f deployment.yaml'
                }
            }

            }
            }
        }
    }
