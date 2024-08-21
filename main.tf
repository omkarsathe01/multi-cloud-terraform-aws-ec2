resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "multi-cloud-vpc"
    App  = "mca"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = var.availability_zone

  tags = {
    Name = "multi-cloud-subnet"
    App  = "mca"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "multi-cloud-route-table"
    App  = "mca"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "multi-cloud-internet-gateway"
    App  = "mca"
  }
}

resource "aws_route" "route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route_table.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "multi-cloud-security-group"
    App  = "mca"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress_rule_allow_outbound" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1

  tags = {
    Name = "egress-rule-allow-outbound"
    App  = "mca"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_allow_http" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  tags = {
    Name = "ingress-rule-allow-http"
    App  = "mca"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_allow_https" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80

  tags = {
    Name = "ingress-rule-allow-https"
    App  = "mca"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule_allow_ssh" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22

  tags = {
    Name = "ingress-rule-allow-ssh"
    App  = "mca"
  }
}

resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet.id
  security_groups             = [aws_security_group.security_group.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
  }

  user_data = <<EOF
#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
IP=$(curl http://checkip.amazonaws.com)
echo http://$IP/
EOF
}
