variable "ami_id" {}
variable "keypair_name" {}
variable "opmng_sg_id" {}
variable "subnet_ids" {}

variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# EC2 Instance
# --------------------------------
resource "aws_instance" "bastion_server" {
  ami                         = var.ami_id
  instance_type               = "t3.small"
  subnet_id                   = element(split(",", var.subnet_ids), 0)
  associate_public_ip_address = true
  vpc_security_group_ids = [
    var.opmng_sg_id
  ]
  key_name = var.keypair_name

  tags = {
    Name              = "${var.name}-bastion-ec2"
    Env               = "${var.environment}"
    aws-exam-resource = "${var.aws-exam-resource}"
  }
  root_block_device {
    encrypted = true
  }
}
