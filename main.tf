provider "aws" {
  region        = "us-east-2"
}

data "aws_vpc" "default" {
  default       = true
}

data "aws_subnet_ids" "default" {
  vpc_id        = data.aws_vpc.default.id
}

resource "aws_security_group" "andrey_security_gr_001" {
  name          = "terraform-example-sg-01"

  ingress {
    from_port   = var.httpd_port
    to_port     = var.httpd_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "andrey_alc_001" {
  #image_id                = "ami-0080d4df14fd99725"
  image_id                = "ami-08be70d36872187b9"
  instance_type           = "t2.micro"
  security_groups         = [aws_security_group.andrey_security_gr_001.id]
  user_data               = <<-EOF
                            #!/bin/bash
                            echo "Hello, World!" > index.html
                            nohup busybox httpd -f -p ${var.httpd_port} &
                            EOF
  #Next section required for correct use within aws_autoscaling_group
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "andrey_aag_001" {
  #availability_zones = ["us-east-2a"]
  vpc_zone_identifier      = data.aws_subnet_ids.default.ids
  launch_configuration     = aws_launch_configuration.andrey_alc_001.name
  min_size                 = 2
  max_size                 = 10
  tag {
    key                    = "Name"
    value                  = "terraform-asg-example-01"
    propagate_at_launch    = true
  }
}

variable "httpd_port" {
  description   = "The port the server will use for HTTP requests"
  type          = number
  default       = 8080
  }

#output "public_ip" {
#  value         = aws_instance.andrey_instance_001.public_ip
#  description   = "The public IP address of the web server"
#  #sensitive     = true
#}
