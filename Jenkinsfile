pipeline {
    agent any

    environment {
        SERVER_IP = '88.218.120.73'
    }

    stages {
        stage('Checkout') {
            steps {
                sh 'mkdir -p ~/.ssh'
                sh 'ssh-keyscan -H github.com >> ~/.ssh/known_hosts'
                sh 'cat ~/.ssh/known_hosts | grep github.com || true'
                sh 'ssh -T git@github.com || true'
                
                git(
                    branch: 'main', 
                    url: 'git@github.com:zhenyapetko/FinalProject.git',
                    credentialsId: 'ssh-private-key' 
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-hugo-site -f docker/Dockerfile .'
                sh 'docker system prune -f'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'cd infrastructure/ansible && ansible-playbook --syntax-check playbook.yml'
                sh 'cd infrastructure/terraform && terraform validate'
            }
        }

        stage('Deploy to Production') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ssh-private-key', 
                    keyFileVariable: 'SSH_KEY'
                )]) {
                    sh '''
                    chmod 600 $SSH_KEY
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY deployer@$SERVER_IP \
                      "cd app && docker-compose down && docker-compose up -d --build"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}