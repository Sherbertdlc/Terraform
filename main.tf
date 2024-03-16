terraform  {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

#vpc creation#
resource "aws_vpc" "project-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}
#create IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project-vpc.id
}

#route table for IGW

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}
#create subnet

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.project-vpc.id
    cidr_block = var.subnet_cidr
    availability_zone = var.availability_zone

    tags = {
        Names = var.subnet_name
    }
}
#associate subnet with route table

resource "aws_route_table_association" "subnet-1" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.public.id
}

#create sg to allow port 22,80 and 443

resource "aws_security_group" "public" {
  name = "public-sg"
  description = "Public internet access"
  vpc_id = aws_vpc.project-vpc.id

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#create network interface with an ip in the subnet created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.public.id]

}

#assign elastic ip to network interface

resource "aws_eip" "elasticip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]
}

#create ubuntu server and install apache2

resource "aws_instance" "web-server-instance" {
  ami = var.ami_id
  instance_type = var.ec2_instance_type
  availability_zone = var.availability_zone
  key_name = var.keyname

  tags = {
    Name = var.instance_name
  }

  user_data = <<-EOF
            #! /bin/bash
            sudo apt update -y
            sudo apt install apache2 -y
            sudo systemctl start apache2
            sudo systemctl enable apache2
            EOF

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  
}

}