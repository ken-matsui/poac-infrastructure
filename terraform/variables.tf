variable "name" {
  default = "poacpm"
}
variable "domain" {
  default = "poac.pm"
}
variable "regions" {
  default = {
    tokyo    = "ap-northeast-1"
    virginia = "us-east-1"
  }
}
data "aws_caller_identity" "self" { }
variable "rds_username" {}
variable "rds_password" {}
