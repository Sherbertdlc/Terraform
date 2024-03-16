output "public_ip" {
  description = "public ip address of ec2"
  value = aws_instance.web-server-instance.public_ip
}
