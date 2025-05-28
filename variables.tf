variable "region" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}

variable "ami" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "ec2_user" {
  type = string
}
variable "ec2_disk_size" {
  type = number
}
variable "ec2_disk_type" {
  type = string
}


variable "platform_name" {
  type = string
}


variable "folder" {
  type = string
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

