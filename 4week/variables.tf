variable "aws_region" {
        description = "Region for VPC"
        default = "ap-northeast-2"
}

variable "vpc_cidr" {
        description = "CIDR for JOINC"
        default = "10.2.0.0/16"
}

variable "availability_zone" {
        description = "Seoul region availability zone"
        type = list
        default = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c", "ap-northeast-2d"]
}

variable "subnet_numbers" {
  type    = list
  default = [10, 20, 30, 40]
}
variable "az_count" {
  type    = list
  default = ["A", "B", "C", "D"]
}
