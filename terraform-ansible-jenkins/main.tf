provider "aws" {
  region = "us-east-1"  
}

resource "aws_instance" "frontend" {
  ami           = "ami-0453ec754f44f9a4a"  
  instance_type = "t2.micro"
  key_name      = "devops"
  tags = {
    Name = "frontend"
  }

  
  user_data = <<-EOT
              #!/bin/bash
              hostnamectl set-hostname c8.local
              EOT
}

resource "aws_instance" "backend" {
  ami           = "ami-0e2c8caa4b6378d8c"  
  instance_type = "t2.micro"
  key_name      = "devops"
  tags = {
    Name = "backend"
  }

  
  user_data = <<-EOT
              #!/bin/bash
              hostnamectl set-hostname u21.local
              EOT
}

output "backend_ip" {
  value = aws_instance.backend.public_ip
}
resource "local_file" "inventory" {
  filename = "./inventory.yaml"
  content  = <<EOF
[frontend]
${aws_instance.frontend.public_ip}
[backend]
${aws_instance.backend.public_ip}
EOF
output "frontend_ip" {
  value = aws_instance.frontend.public_ip
}
}




