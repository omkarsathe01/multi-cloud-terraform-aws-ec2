variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zone" {
  type    = string
  default = "us-east-1a"
}

variable "ami" {
  type    = string
  default = "ami-0e86e20dae9224db8"
}

variable "key_name" {
  type    = string
  default = "microservice-app-keypair"
}
