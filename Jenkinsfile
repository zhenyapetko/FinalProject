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

        stage('Check Files') {
            steps {
                sh '''
                echo "📁 Current directory:"
                pwd
                echo "📁 Files in directory:"
                ls -la
                echo "📁 Looking for docker-compose.yml:"
                find . -name "docker-compose.yml" -type f
                '''
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

        stage('Check SSH Connection') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ssh-private-key', 
                    keyFileVariable: 'SSH_KEY'
             )]) {
                    sh '''
                    echo "🔧 Testing SSH connection..."
                    chmod 600 $SSH_KEY
                    echo "SSH key path: $SSH_KEY"
                    ls -la $SSH_KEY
                    echo "=== Trying to connect ==="
                    ssh -i $SSH_KEY -v -o StrictHostKeyChecking=no deployer@$SERVER_IP "whoami" || echo "SSH connection failed"
                    '''
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

                    # Добавляем ключ сервера в known_hosts
                    mkdir -p ~/.ssh
                    ssh-keyscan -H $SERVER_IP >> ~/.ssh/known_hosts
            
                    # Создаем папку app на сервере
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY deployer@$SERVER_IP "mkdir -p ~/app"
            
                    # Копируем docker-compose.yml
                    scp -o StrictHostKeyChecking=no -i $SSH_KEY ./docker/docker-compose.yml deployer@$SERVER_IP:~/app/
            
                    # Копируем папку docker
                    scp -o StrictHostKeyChecking=no -i $SSH_KEY -r ./docker/ deployer@$SERVER_IP:~/app/
            
                    # Копируем папку src
                    scp -o StrictHostKeyChecking=no -i $SSH_KEY -r ./src/ deployer@$SERVER_IP:~/app/
            
                    # Запускаем на сервере
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY deployer@$SERVER_IP \
                        "cd ~/app && \
                        docker rm -f portfolio-site 2>/dev/null || true && \
                        docker-compose -f docker/docker-compose.yml down --remove-orphans && \
                        docker-compose -f docker/docker-compose.yml up -d --build"
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