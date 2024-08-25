# resource "aws_vpc" "vpc" {
#   cidr_block = var.vpc_cidr_block

#   tags = {
#     Name = "multi-cloud-vpc"
#     App  = "mca"
#   }
# }

# resource "aws_subnet" "subnet" {
#   vpc_id            = aws_vpc.vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
#   availability_zone = var.availability_zone

#   tags = {
#     Name = "multi-cloud-subnet"
#     App  = "mca"
#   }
# }

# resource "aws_route_table" "route_table" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "multi-cloud-route-table"
#     App  = "mca"
#   }
# }

# resource "aws_route_table_association" "route_table_association" {
#   subnet_id      = aws_subnet.subnet.id
#   route_table_id = aws_route_table.route_table.id
# }

# resource "aws_internet_gateway" "internet_gateway" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "multi-cloud-internet-gateway"
#     App  = "mca"
#   }
# }

# resource "aws_route" "route" {
#   destination_cidr_block = "0.0.0.0/0"
#   route_table_id         = aws_route_table.route_table.id
#   gateway_id             = aws_internet_gateway.internet_gateway.id
# }

# resource "aws_security_group" "security_group" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "multi-cloud-security-group"
#     App  = "mca"
#   }
# }

# resource "aws_vpc_security_group_egress_rule" "egress_rule_allow_outbound" {
#   security_group_id = aws_security_group.security_group.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1

#   tags = {
#     Name = "egress-rule-allow-outbound"
#     App  = "mca"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress_rule_allow_http" {
#   security_group_id = aws_security_group.security_group.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = "tcp"
#   from_port   = 443
#   to_port     = 443

#   tags = {
#     Name = "ingress-rule-allow-http"
#     App  = "mca"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress_rule_allow_https" {
#   security_group_id = aws_security_group.security_group.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = "tcp"
#   from_port   = 80
#   to_port     = 80

#   tags = {
#     Name = "ingress-rule-allow-https"
#     App  = "mca"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "ingress_rule_allow_ssh" {
#   security_group_id = aws_security_group.security_group.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = "tcp"
#   from_port   = 22
#   to_port     = 22

#   tags = {
#     Name = "ingress-rule-allow-ssh"
#     App  = "mca"
#   }
# }

# resource "aws_instance" "instance" {
#   ami                         = var.ami
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.subnet.id
#   security_groups             = [aws_security_group.security_group.id]
#   associate_public_ip_address = true
#   key_name                    = var.key_name

#   root_block_device {
#     volume_type = "gp3"
#     volume_size = 30
#   }

#   user_data = <<EOF
# #!/bin/bash
# sudo apt update
# sudo apt install nginx -y
# sudo systemctl start nginx
# sudo touch /etc/nginx/sites-available/myserver
# echo 'server {
#   listen 0.0.0.0:80;
#   server_name localhost;

#   location / {
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header Host $http_host;
#     proxy_set_header X-NginX-Proxy true;

#     proxy_pass http://127.0.0.1:3000/;
#     proxy_redirect off;
#   }

#   location /overview {
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header Host $http_host;
#     proxy_set_header X-NginX-Proxy true;

#     proxy_pass http://127.0.0.1:3000/overview;
#     proxy_redirect off;
#   }

#   location /api {
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header Host $http_host;
#     proxy_set_header X-NginX-Proxy true;

#     proxy_pass http://127.0.0.1:3000/api;
#     proxy_redirect off;
#   }
# }' | sudo tee /etc/nginx/sites-available/myserver > /dev/null
# echo 'server {
#   listen 8080 default_server;
#   listen [::]:8080 default_server;

#   root /var/www/html;

#   index index.html index.htm index.nginx-debian.html;

#   server_name _;

#   location / {
#     try_files $uri $uri/ =404;
#   }
# }' | sudo tee /etc/nginx/sites-available/default > /dev/null
# sudo ln -s /etc/nginx/sites-available/myserver /etc/nginx/sites-enabled/
# mkdir ~/mkdir multi-cloud-terraform-app
# cd ~/multi-cloud-terraform-app/
# git pull https://github.com/omkarsathe01/multi-cloud-terraform-app.git
# sudo apt install npm -y
# sudo systemctl restart nginx
# node server.js
# EOF
# }

# resource "aws_vpc" "microservice_app_vpc" {
#   cidr_block = "192.168.0.0/27"

#   tags = {
#     Name = "microservice-app-vpc"
#     app  = "microservice"
#   }
# }

# resource "aws_subnet" "microservice_app_public_subnet" {
#   vpc_id            = aws_vpc.microservice_app_vpc.id
#   availability_zone = "us-east-1b"
#   cidr_block        = "192.168.0.16/28"

#   tags = {
#     Name = "microservice-app-public-subnet"
#     app  = "microservice"
#     vpc  = "microservice-app-vpc"
#   }
# }

# resource "aws_subnet" "microservice_app_private_subnet" {
#   vpc_id     = aws_vpc.microservice_app_vpc.id
#   cidr_block = "192.168.0.0/28"

#   tags = {
#     Name = "microservice-app-private-subnet"
#     app  = "microservice"
#     vpc  = "microservice-app-vpc"
#   }
# }

# resource "aws_vpc" "vpc-0d8fef82400355a15" {
#   cidr_block = "10.0.0.0/16"
# }

# resource "aws_subnet" "subnet-0fd0e5bfeaa747624" {
#   vpc_id     = aws_vpc.vpc-0d8fef82400355a15.id
#   cidr_block = "10.0.0.0/24"
# }

# resource "aws_route_table" "rtb-0531fad4aeb177114" {
#   vpc_id = aws_vpc.microservice_app_vpc.id
# }

# resource "aws_route_table" "rtb-0e46efcf11401263d" {
#   vpc_id = aws_vpc.vpc-0d8fef82400355a15.id
# }

# resource "aws_route_table" "rtb-047bd9d51f8b1eadb" {
#   vpc_id = aws_vpc.microservice_app_vpc.id
# }

# resource "aws_internet_gateway" "microservice_app_internet_gateway" {
#   vpc_id = "vpc-009d403e2d3970c3a"

#   tags = {
#     Name   = "microservice-app-internet-gateway"
#     app    = "microservice"
#     subnet = "microservice-app-public-subnet"
#     vpc    = "microservice-app-vpc"
#   }
# }

# resource "aws_default_network_acl" "acl-0427d4330bcec56a8" {
#   default_network_acl_id = "acl-0427d4330bcec56a8"
#   subnet_ids             = ["subnet-0fd0e5bfeaa747624"]

#   egress {
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#     protocol   = "-1"
#     rule_no    = 100
#   }

#   ingress {
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#     protocol   = "-1"
#     rule_no    = 100
#   }
# }

# resource "aws_default_network_acl" "acl-0194e99bf55185cf7" {
#   default_network_acl_id = "acl-0194e99bf55185cf7"
#   subnet_ids             = ["subnet-02219e0caf5c3fa8a", "subnet-0b885c401c63ba800"]

#   egress {
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     protocol   = "-1"
#     from_port  = 0
#     to_port    = 0
#     rule_no    = 100
#   }

#   ingress {
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     protocol   = "-1"
#     rule_no    = 100
#     from_port  = 0
#     to_port    = 0
#   }
# }

# resource "aws_security_group" "sg-07b2516377137b5ce" {
#   description = "default VPC security group"
#   name        = "default"
# }

# resource "aws_security_group" "sg-04035163f45ec47d3" {
#   description = "microservice-app-security-group created 2024-08-15T05:02:31.948Z"
# }

# resource "aws_security_group" "sg-06c03239b9aaba9db" {
#   description = "default VPC security group"
# }

# resource "aws_route_table_association" "rtbassoc-019dc5d9fdd8a44fc" {
#   route_table_id = aws_route_table.rtb-0531fad4aeb177114.id
#   subnet_id      = ""
# }
