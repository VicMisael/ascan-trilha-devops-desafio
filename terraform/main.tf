terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.73.0"
    }
  }

}
provider "aws" {
    region="us-east-1"
}



resource "aws_security_group" "web-node" {
  name = "Security group"
  description = "Web Security Group"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "helloworld_instance" {
 ami = "ami-08c40ec9ead489470" // Ubuntu latest
 instance_type = "t2.micro" // Free Tier 
 tags = { 
 Name = "HelloWorld" 
 } 
 security_groups = ["${aws_security_group.web-node.name}"]
}
