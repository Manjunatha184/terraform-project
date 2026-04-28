# Security Group
resource "aws_security_group" "web_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Public EC2 (NGINX)
resource "aws_instance" "public_vm" {
  ami           = "ami-0f5ee92e2d63afc18" # Amazon Linux (ap-south-1)
  instance_type = "t2.micro"
  subnet_id     = var.public_subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOT
    #!/bin/bash
    sudo apt update -y || sudo yum update -y

    # Install nginx (works for Ubuntu & Amazon Linux)
    sudo apt install nginx -y || sudo amazon-linux-extras install nginx1 -y

    sudo systemctl start nginx
    sudo systemctl enable nginx

    echo "Hello from Public EC2 (NGINX)" | sudo tee /var/www/html/index.html /usr/share/nginx/html/index.html
    EOT

  tags = { Name = "Public-VM" }
}

# Private EC2
resource "aws_instance" "private_vm" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  subnet_id     = var.private_subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "Private-VM" }
}