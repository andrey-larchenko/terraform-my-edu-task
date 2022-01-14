provider "aws" {
  region        = "us-east-2"
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

resource "aws_instance" "andrey_instance_001" {
  ami                     = "ami-0080d4df14fd99725"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.andrey_security_gr_001.id]
  user_data               = <<-EOF
                            #!/bin/bash
                            echo "Hello, World!" > index.html
                            nohup busybox httpd -f -p ${var.httpd_port} &
                            EOF
  tags                    = {
    Name                  = "terraform-example-01"
  }
}

variable "httpd_port" {
  description   = "The port the server will use for HTTP requests"
  type          = number
  default       = 8080
  }

output "public_ip" {
  value         = aws_instance.andrey_instance_001.public_ip
  description   = "The public IP address of the web server"
  #sensitive     = true
}
