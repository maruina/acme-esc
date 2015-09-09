variable "access_key" { 
  description = "AWS access key"
}


variable "secret_key" { 
  description = "AWS secret access key"
}


variable "key_path" {
  description = "AWS key path"  
}


variable "key_name" {
  description = "AWS key name"
}


variable "region"     { 
  description = "AWS region"
  default     = "us-east-1" 
}


variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "172.31.0.0/16"
}


variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  default     = "172.31.1.0/24"
}


variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  default     = "172.31.2.0/24"
}


# Debian 7 AMI
variable "debian_amis" {
  description = "Debian 7 AMI"
  default = {
    us-east-1 = "ami-e0efab88"
  }
}