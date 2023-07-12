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
  name	=	"blog"
  
  vpc_id	=	module.vpc.vpc_id
  ingress_rules	=	["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks	=	["0.0.0.0/0"]
  egress_rules	=	["all-all"]
  egress_cidr_blocks	=	["0.0.0.0/0"]
  
}

resource "aws_instance" "blog" {
  ami				=	data.aws_ami.app_ami.id
  instance_type				=	var.instance_type
  vpc_security_group_ids				=	[module.blog_sg.security_group_id]
  subnet_id				=	module.vpc.public_subnets[0]
  
  tags = {
    Name = "HelloWorld"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "blog-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = module.blog_sg.security_group_id

  target_groups = [
    {
      name_prefix      = "blog"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = aws_instance.blog.id
          port = 80
        }
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
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
  
