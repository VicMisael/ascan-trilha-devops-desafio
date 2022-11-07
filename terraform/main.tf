terraform {
   aws = {
 source = "hashicorp/aws"
 version = "~> 3.28"
 }
}
provider "aws" {
    region="us-east-1"
}

resource "aws_instance" "helloworld_instance" {
 ami = "ami-09dd2e08d601bff67" 
 instance_type = "t2.micro" 
 tags = { 
 Name = "HelloWorld" 
 } 
}

