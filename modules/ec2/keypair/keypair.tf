variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# key pair
# --------------------------------
resource "aws_key_pair" "keypair" {
  key_name   = "${var.name}-keypair"
  public_key = file("${path.module}/engineedExam00169.pub")

  tags = {
    Name              = "${var.name}-keypair"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

output "keypair_name" { value = aws_key_pair.keypair.key_name }
