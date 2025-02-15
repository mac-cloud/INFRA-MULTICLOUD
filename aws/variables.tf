variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "aws_profile" {
    type = string
    default = "default"
  
}
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}
variable "private_subnets" {
    type = list(string)
    default = [
        "10.0.1.0/24",
        "10.0.2.0/24"
    ]
}
variable "node_group_desired_size" {
    type = number
    default = 2
}
variable "node_group_instance_type" {
    type = string
    default = "t3.medium"
}