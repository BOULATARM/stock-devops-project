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

# --- VARIABLES ---
variable "key_name" {
  default = "devops-key"
}

# --- AMI & RÉSEAU ---
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" { default = true }

resource "aws_security_group" "devops_sg" {
  name        = "devops-project-sg"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins UI
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Plage NodePort
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flux interne
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -----------------------------
# SUBNET DANS ZONE SUPPORTÉE
# -----------------------------
resource "aws_subnet" "devops_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 100)
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "devops-subnet-1a"
  }
}

# --- INSTANCES ---
resource "aws_instance" "nodes" {
  for_each = {
    "master"  = { type = "t3.small", role = "master" }   # K3s control plane
    "worker"  = { type = "t3.micro", role = "worker" }   # K3s worker + application
  }

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.devops_subnet.id
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "node-${each.key}"
    Role = each.value.role
  }
}

# --- OUTPUTS ---
output "ips" {
  value = { for k, v in aws_instance.nodes : k => v.public_ip }
}