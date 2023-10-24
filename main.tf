terraform {
  cloud {
    organization = "Ayodev"

    workspaces {
      name = "demo"
    }
  }
}
provider "aws" {
  region = "us-west-1" # Set your desired AWS region
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "my_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-west-1a" # Set your preferred availability zone consistently
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-1"
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1c" # Set your preferred availability zone consistently
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-2"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.my_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_subnet_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.my_subnet_1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_subnet_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.my_route_table.id
}
resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "My security group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Limit this to specific IPs if possible
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Add more specific ingress rules for your needs

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add more specific egress rules for your needs

  tags = {
    Name = "allow_web"
  }
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0cbd40f694b804622" # Replace with your desired AMI
  instance_type = "t2.micro"              # Replace with your desired instance type
  subnet_id     = aws_subnet.my_subnet_1.id

  vpc_security_group_ids = [aws_security_group.my_sg.id]

  # Define your EC2 instance configuration here
}

resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false # Change this if needed

  subnets = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  enable_http2 = true

  security_groups = [aws_security_group.my_sg.id]

  # Define listeners, target groups, and other Load Balancer configuration here
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}
