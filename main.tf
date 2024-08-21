resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = var.availability_zone
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.multi_cloud_aws_vpc.id
}

resource "aws_route" "route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route_table.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

# resource "aws_security_group" "security_group" {
#   vpc_id = aws_vpc.multi_cloud_aws_vpc.id

#   ingress = {
#     from_port = 80
#     to_port = 80
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_instance" "instance" {
#   ami                         = var.ami
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.subnet.id
#   security_groups             = [aws_security_group.security_group.id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name
#   user_data                   =
#   <<EOF
#     sudo apt update
#     sudo apt install nginx
#   EOF
# }
