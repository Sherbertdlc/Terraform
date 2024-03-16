variable "region" {
  description = "aws_region"
  type = string
  default = "us-east-1"
}

variable "availability_zone" {
    description = "availability zone"
    type = string
    default = "us-east-1a"
}

variable "vpc_name" {
    description = "vpc name"
    type = string
    default = "project-vpc"
  
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  type = string
  default = "10.0.0.0/16"
}

variable "security_group_name" {
  description = "name given to SG"
  type = string
  default = "website-acess"
}

variable "ec2_instance_type" {
  description = "ec2 instance type"
  type = string
  default = "t2.micro"
}

variable "instance_name" {
    description = "name given to instance"
    type = string
    default = "my_instance"
}
variable "ami_id" {
    description = "Ubuntu ami id number"
    type = string
    default = "ami-07d9b9ddc6cd8dd30"
  
}

variable "subnet_cidr" {
  description = "subnet cidr"
  type = string
  default = "10.0.1.0/24"
}

variable "subnet_name" {
    description = "subnet name"
    type = string
    default = "project-subnet"
  
}

variable "keyname" {
  description = "key pair"
  type = string
  default = "project-key"
}