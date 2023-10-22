terraform {
    required_providers {
        aws = {
        source = "hashicorp/aws"
        version = "5.22.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "vpc" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.0.0/16"
    availability_zone = "us-east-1a"

    tags = {
        Name = "minha-vpc"
    }
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "minha-subnet"
    }
}

resource "aws_internet_gatway" "gw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "meu-ig"
    }
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.vpc.id
    
    route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gatway.gw.id
    }

    tags = {
        Name = "minha-rt"
    }
}

resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_key_pair" "deployer" {
    key_name = "video-imersao-key"
    public_key = ""
}

resource "aws_instance" "web" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet.id
    associate_public_ip_address = true
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.security.id]

    tags = {
        Name = "minha-ec2"
    }
}

resource "aws_security_group" "security_group" {
    name = "imersao-security-group"
    description = "SG Liberado"
    vpc_id = aws_vpc.vpc.id

    ingress {
        description = "Liberação de todas as portas"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        description = "Liberação de todas as portas"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "imersao-security-group"
    }
}

output "ip_ec2" {
  value       = aws_instance.web.public_ip
  sensitive   = true
  description = "description"
  depends_on  = []
}
