provider "aws" {
  region        = "us-east-2"
}

resource "aws_instance" "andrey_instance_001" {
  ami           = "ami-0080d4df14fd99725"
  instance_type = "t2.micro"
  tags          = {
    Name        = "terraform-example-01"
  }
}
