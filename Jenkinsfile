pipeline {
    agent any

    environment {
        SERVER_IP = '88.218.120.73'
        SSH_KEY = credentials('ssh-private-key')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                url: 'git@gitlab.com:your-username/FinalProject.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-hugo-site -f docker/Dockerfile .'
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
                sh '''
                echo "$SSH_KEY" > /tmp/ssh_key
                chmod 600 /tmp/ssh_key
                ssh -o StrictHostKeyChecking=no -i /tmp/ssh_key deployer@$SERVER_IP \
                  "cd app && docker-compose down && docker-compose up -d --build"
                '''
            }
        }
    }

    post {
        success {
            slackSend (channel: '#deployments', 
                      message: "✅ SUCCESS: Job ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
        failure {
            slackSend (channel: '#deployments',
                      message: "❌ FAILED: Job ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
    }
}