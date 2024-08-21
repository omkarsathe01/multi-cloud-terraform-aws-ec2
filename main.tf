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
sudo mkdir /etc/nginx/sites-available/myserver
echo 'server {
  listen 0.0.0.0:80;
  server_name localhost;

  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;

    proxy_pass http://127.0.0.1:3000/;
    proxy_redirect off;
  }

  location /overview {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;

    proxy_pass http://127.0.0.1:3000/overview;
    proxy_redirect off;
  }

  location /api {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;

    proxy_pass http://127.0.0.1:3000/api;
    proxy_redirect off;
  }
}' | sudo tee /etc/nginx/sites-available/myserver > /dev/null
echo 'server {
  listen 8080 default_server;
  listen [::]:8080 default_server;

  root /var/www/html;

  index index.html index.htm index.nginx-debian.html;

  server_name _;

  location / {
    try_files $uri $uri/ =404;
  }
}' | sudo tee /etc/nginx/sites-available/default > /dev/null
sudo ln -s /etc/nginx/sites-available/myserver /etc/nginx/sites-enabled/
cd ~
git pull https://github.com/omkarsathe01/multi-cloud-terraform-app.git
cd multi-cloud-terraform-app
sudo apt install npm -y
sudo systemctl restart nginx
node server.js
EOF
}
