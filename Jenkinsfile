pipeline {
    agent any

    environment {

        TF_VAR_FRONTEND_IP = ''
        TF_VAR_BACKEND_IP = ''
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init and Apply') {
            steps {
                script {
                    sh '''
                    cd terraform
                    terraform init
                    terraform apply -auto-approve
                    '''
                    env.TF_VAR_FRONTEND_IP = sh(script: "terraform output -raw frontend_ip", returnStdout: true).trim()
                    env.TF_VAR_BACKEND_IP = sh(script: "terraform output -raw backend_ip", returnStdout: true).trim()

                    echo "Frontend IP: ${env.TF_VAR_FRONTEND_IP}"
                    echo "Backend IP: ${env.TF_VAR_BACKEND_IP}"
                }
            }
        }

        stage('Prepare Ansible Inventory') {
            steps {
                script {
                    writeFile file: 'ansible/inventory/terraform_inventory.ini', text: """
[frontend]
${env.TF_VAR_FRONTEND_IP}

[backend]
${env.TF_VAR_BACKEND_IP}
"""
                }
            }
        }

        stage('Ansible - Configure Frontend') {
            steps {
                script {
                    sh '''
                    cd ansible
                    ansible-playbook -i inventory/terraform_inventory.ini playbooks/frontend.yml
                    '''
                }
            }
        }
    }
