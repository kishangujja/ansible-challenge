pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws')  // ID from Jenkins credentials store
        AWS_SECRET_ACCESS_KEY = credentials('aws')  // ID from Jenkins credentials store
        ANSIBLE_PRIVATE_KEY_FILE = "devops"
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
                    cd terraform-ansible-jenkins
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
                    writeFile file: '/var/lib/jenkins/workspace/ansible-terraform-jenkins/terraform-ansible-jenkins/inventory.yaml', text: """
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
            // Run the Ansible playbook for the frontend VM to install and configure NGINX
            sh '''
            cd ansible
            ansible-playbook -i /var/lib/jenkins/workspace/ansible-terraform-jenkins/terraform-ansible-jenkins/inventory.yaml --private-key devops playbooks/frontend.yml
            '''
        }
    }
}

stage('Ansible - Configure Backend') {
    steps {
        script {
            // Run the Ansible playbook for the backend VM to install and configure Netdata
            sh '''
            cd ansible
            ansible-playbook -i /var/lib/jenkins/workspace/ansible-terraform-jenkins/terraform-ansible-jenkins/inventory.yaml --private-key devops playbooks/backend.yml
            '''
        }
    }
}

    }
}
