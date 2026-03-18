terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# VARIABLES
# -----------------------------
variable "key_name" {
  description = "Nom de la paire de clés AWS existante"
  type        = string
  default     = "devops-key"
}

variable "instance_type_master" {
  description = "Type d'instance pour master + Jenkins"
  type        = string
  default     = "t3.small"
}

variable "instance_type_worker" {
  description = "Type d'instance pour worker"
  type        = string
  default     = "t3.micro"
}

# -----------------------------
# UBUNTU 24.04 LTS AMI
# -----------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------
# DEFAULT VPC + SUBNET
# -----------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -----------------------------
# SECURITY GROUP
# -----------------------------
resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  description = "Security group for Jenkins + Kubernetes"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask app / NodePort
  ingress {
    description = "NodePort app"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API (accessible publicly for demo; you can restrict later)
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal communication between nodes in same SG
  ingress {
    description = "All traffic inside security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-project-sg"
  }
}

# -----------------------------
# MASTER + JENKINS
# -----------------------------
resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_master
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = {
    Name = "k8s-master-jenkins"
    Role = "master-jenkins"
  }
}

# -----------------------------
# WORKER
# -----------------------------
resource "aws_instance" "worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_worker
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = {
    Name = "k8s-worker"
    Role = "worker"
  }
}

# -----------------------------
# OUTPUTS
# -----------------------------
output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "worker_public_ip" {
  value = aws_instance.worker.public_ip
}

output "worker_private_ip" {
  value = aws_instance.worker.private_ip
}