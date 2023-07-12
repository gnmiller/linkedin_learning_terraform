data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

module "blog_sg" {
  source	=	"terraform-aws-modules/security-group/aws"
  version	=	"5.1.0"
  name	=	"blog_sg"
  
  vpc_id	=	module.vpc.public_subnets[0]
  ingress_rules	=	["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks	=	["0.0.0.0/0"]
  egress_rules	=	["all-all"]
  egress_cidr_blocks	=	["0.0.0.0/0"]
  
}

resource "aws_instance" "blog" {
  ami           			= module.vpc.public_subnets[0]
  instance_type 			= var.instance_type
  vpc_security_group_ids = [module.blog_sg.security_group_id]
  
  tags = {
    Name = "HelloWorld"
  }
}
  
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev_vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
  
resource "aws_security_group" "blog" {
  name 	=	"blog-sg"
  description	=	"Allow 80/443 IN, Allow ALL OUT"
  
  vpc_id 		=	module.vpc.public_subnets[0]
}
  
resource "aws_security_group_rule" "blog_http_in" {
	type 		= "ingress"
	from_port 		= 80
	to_port 		= 80
	protocol		= "tcp"
	cidr_blocks 		= ["0.0.0.0/0"]
	security_group_id		= aws_security_group.blog.id
}
  
resource "aws_security_group_rule" "blog_https_in" {
	type 		= "ingress"
	from_port 		= 443
	to_port 		= 443
	protocol		= "tcp"
	cidr_blocks 		= ["0.0.0.0/0"]
	security_group_id		= aws_security_group.blog.id
}
  
resource "aws_security_group_rule" "blog_all_out" {
	type 		= "egress"
	from_port 		= 0
	to_port 		= 0
	protocol		= -1
	cidr_blocks 		= ["0.0.0.0/0"]
	security_group_id		= aws_security_group.blog.id
}
  
