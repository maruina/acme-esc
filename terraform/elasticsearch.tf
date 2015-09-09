# Define Elasticsearch IAM profile
resource "aws_iam_instance_profile" "esc_profile" {
    name = "esc-profile"
    roles = ["${aws_iam_role.esc_role.name}"]
}


# Define Elasticsearch IAM role
resource "aws_iam_role" "esc_role" {
    name = "esc-role"
    path = "/"
    assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": ["ec2:DescribeInstances"],
                "Effect": "Allow",
                "Resource": ["*"]
            }
        ]
    }
EOF
}


# Define Elasticsearch cluster security group
resource "aws_security_group" "esc_instances" {
    name = "esc-instances"
    description = "Rules for Elasticsearch Cluster"

    ingress {
        from_port = 9200
        to_port = 9200
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${aws_instance.nat.private_ip}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
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
        cidr_blocks = ["${aws_instance.nat.private_ip}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "esc-instances-sg"
    }
}


# Define Elastic Load Balancer security group
resource "aws_security_group" "esc_elb" {
    name = "esc-elb"
    description = "Rules for Elastic Load Balancer"

    ingress {
        from_port = 9200
        to_port = 9200
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "esc-elb-sg"
    }
}


# Create the Elasticsearch instances
resource "aws_instance" "esc" {
  count = 3
  ami = "${lookup(var.debian_amis, var.region)}"
  instance_type = "t2.small"
  subnet_id = "${aws_subnet.us-east-1a-private.id}"
  security_groups = ["${aws_security_group.esc_instances.id}"]
  key_name = "${var.key_name}"
  source_dest_check = false
  iam_instance_profile = "${esc_profile}"
  tags = { 
    Name = "acme-esc-node-${count.index}"
  }  
}


# Create the Elastic Load Balancer
resource "aws_elb" "esc-elb" {
  name = "acme-esc-elb"
  subnets = ["${aws_subnet.us-east-1a-public.id}"]
  security_groups = ["${aws_security_group.esc_elb.id}"]
  listener {
    instance_port = 9200
    instance_protocol = "http"
    lb_port = 9200
    lb_protocol = "http"
  }
  instances = ["${aws_instance.esc.*.id}"]
}


