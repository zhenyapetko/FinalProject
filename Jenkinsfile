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

        stage('Install Tools') {
            steps {
                sh '''
                     # Устанавливаем Python и pip
                    apt-get update && apt-get install -y python3 python3-pip
                    # ИЛИ для Alpine:
                    # apk add python3 py3-pip
                    
                    # Устанавливаем Ansible
                    pip3 install ansible
                    
                    # Проверяем установку
                    ansible --version
                    ansible-playbook --version
                '''
            }
        }


        stage('Build Docker Image') {
    steps {
        sh 'docker-compose -f docker/docker-compose.yml build'
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