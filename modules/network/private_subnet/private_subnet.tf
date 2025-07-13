variable "vpc_id" {}
variable "cidrs" {}
variable "azs" {}
variable "type" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Private App Subnet
# --------------------------------
resource "aws_subnet" "private_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = element(split(",", var.cidrs), count.index)
  availability_zone = element(split(",", var.azs), count.index)
  count             = length(split(",", var.cidrs))

  lifecycle { create_before_destroy = true }

  map_public_ip_on_launch = false

  tags = {
    Name              = "${var.name}.${var.type}.${element(split(",", var.azs), count.index)}"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

# --------------------------------
# Route Table Public
# --------------------------------
resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name              = "${var.name}-${var.type}-rt"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

resource "aws_route_table_association" "private_association" {
  count          = length(split(",", var.cidrs))
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

output "subnet_ids" { value = join(",", aws_subnet.private_subnet.*.id) }
