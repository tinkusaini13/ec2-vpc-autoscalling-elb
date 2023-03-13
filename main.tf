# addon provider
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA5SFDHCTOKUKI"
  secret_key = "Y9aNmQWESFzkS5KmjZryxT43YFGnjk85aCXn"
}

#create instance

resource "aws_instance" "sample" {
  ami             = "ami-0e07dcaca348a0e68"       
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main.id
  key_name        = "saini"
  security_groups = [aws_security_group.sample.id]
}

#create vpc

resource "aws_vpc" "samplevpc" {
  cidr_block = "10.10.0.0/16"
}

#create subnet

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.samplevpc.id
  cidr_block = "10.10.1.0/24"
}


# create security group

resource "aws_security_group" "sample" {
  vpc_id = aws_vpc.samplevpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



#################################################################################


# Create an ELB
resource "aws_elb" "example" {
  name            = "example-elb"
  security_groups = ["aws_security_group.sample.id"]
  subnets         = ["aws_subnet.main.id"]    ################################################# BECOME ERROR############################
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}

# Create an autoscaling group for the ELB
resource "aws_autoscaling_group" "example" {
  name                      = "example-autoscaling-group"
  launch_configuration      = aws_launch_configuration.example.id
  vpc_zone_identifier       = ["aws_subnet.main.id"]
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  load_balancers            = [aws_elb.example.name]

  #tag_specifications {
  #  resource_type = "autoscaling_group"
    #tags = {
    #  Name = "example-autoscaling-group"
    #}
  #}
}

# Create a launch configuration for the autoscaling group
resource "aws_launch_configuration" "example" {
  name_prefix     = "example-"
  image_id        = "ami-0e07dcaca348a0e68"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sample.id]
}
