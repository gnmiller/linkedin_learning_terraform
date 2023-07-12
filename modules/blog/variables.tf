variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter" {
  description = "Name filter and owner for AMIs"
  type = object({
    name  = string
    owner = string
  })
  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami
  } 
}

variable "environment"{
  description = "tag for environment (dev)"
  type  = object({
    name        = string
    network_pfx = string
  })
  default = {
    name = "dev"
    network_pfx = "10.0"
  }
}

variable "asg_min_size"{
  description = "min instances in scaler group"
  default     = 1
}
variable "asg_max_size"{
  description = "max instances in scaler group"
  default     = 2
}