variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  type = string
  default = "10.0.10.0/24"
}

variable "availability_zone" {
  type = string
  default ="a"

}

variable "ingress_cidr_blocks" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "nginx_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "haproxy_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_name" {
  type    = string
  default = "terraform-ansible-vpc"
}

variable "ssh_key" {
  type    = string
  default = "/home/bryan/.ssh/id_rsa"
}