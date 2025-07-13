variable "vpc_id" {}
variable "cidrs" {}
variable "azs" {}
variable "name" {}
variable "environment" {}
variable "aws-exam-resource" { default = true }

# --------------------------------
# Internet Gateway
# --------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name              = "${var.name}-igw"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

# --------------------------------
# Public Subnet
# --------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = element(split(",", var.cidrs), count.index)
  availability_zone = element(split(",", var.azs), count.index)
  count             = length(split(",", var.cidrs))

  lifecycle { create_before_destroy = true }

  map_public_ip_on_launch = true

  tags = {
    Name              = "${var.name}.${element(split(",", var.azs), count.index)}"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

# --------------------------------
# Route Table Public
# --------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name              = "${var.name}-rt"
    Env               = var.environment
    aws-exam-resource = var.aws-exam-resource
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(split(",", var.cidrs))
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

output "subnet_ids" { value = join(",", aws_subnet.public_subnet.*.id) }
