# Setup AWS provider
provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}


# Define VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags { 
    Name = "acme-vpc" 
  }
}


# Define VPC Internet Gateway
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.vpc.id}"
}


# Define NAT Instance Security Group
resource "aws_security_group" "nat" {
    name = "NAT-SG"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "nat-sg"
    }
}


# Create NAT instance
resource "aws_instance" "nat" {
    ami = "ami-303b1458"
    availability_zone = "us-east-1a"
    instance_type = "m1.small"
    key_name = "${var.key_name}"
    security_groups = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.us-east-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "nat-acme-vpc"
    }
}


# Associate EIP to NAT instance
resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}


# Create Public subnet
resource "aws_subnet" "us-east-1a-public" {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1a"

    tags {
        Name = "acme-public-subnet"
    }
}


# Create Public Subnet route table
resource "aws_route_table" "us-east-1a-public" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "acme-public-subnet-route-table"
    }
}


# Associate Public Subnet route table with Public Subnet
resource "aws_route_table_association" "us-east-1a-public" {
    subnet_id = "${aws_subnet.us-east-1a-public.id}"
    route_table_id = "${aws_route_table.us-east-1a-public.id}"
}


# Create Private subnet
resource "aws_subnet" "us-east-1a-private" {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-east-1a"

    tags {
        Name = "acme-private-subnet"
    }
}


# Create Private Subnet route table
resource "aws_route_table" "us-east-1a-private" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "acme-private-subnet-route-table"
    }
}


# Associate Private Subnet route table with Private Subnet
resource "aws_route_table_association" "us-east-1a-private" {
    subnet_id = "${aws_subnet.us-east-1a-private.id}"
    route_table_id = "${aws_route_table.us-east-1a-private.id}"
}