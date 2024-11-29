
resource "aws_instance" "bastion_host" {
  instance_type                   = var.instance_type
  associate_public_ip_address     = true #turn it false if behind vpn
  subnet_id                       = var.public_subnet_id
  key_name                        = var.key_name
  ami                             = var.ami_id
  vpc_security_group_ids          = [var.vpc_security_group_ids]
  user_data                       = file("user_data/data.sh")
  tags = {
    Name = "jump-box"
  }
}