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
        sh 'docker-compose -f docker/docker-compose.yml build'
    }
}

        stage('Run Ansible Test') {
            steps {
                sh '''
                    docker run --rm \\
                    -v $(pwd):/app \\
                    alpine sh -c "apk add ansible && \\
                    cd /app/infrastructure/ansible && \\
                    ansible-playbook --syntax-check playbook.yml"
                '''
            }
        }

        stage('Run Terraform Test') {
            steps {
                script {
                        echo "🔧 Terraform test skipped - not using AWS"
                        echo "Terraform config is for demonstration purposes only"
                        // Пропускаем тест так как Terraform не используется по-настоящему
            }
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
            
                    # Копируем только нужные файлы на сервер
                    scp -i $SSH_KEY docker-compose.yml deployer@$SERVER_IP:~/app/
                    scp -i $SSH_KEY -r docker/ deployer@$SERVER_IP:~/app/
                    scp -i $SSH_KEY -r src/ deployer@$SERVER_IP:~/app/
            
                    # Запускаем на сервере
                    ssh -i $SSH_KEY deployer@$SERVER_IP \
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