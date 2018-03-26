variable "name" {
  default = "poacpm"
}

variable "regions" {
  default = {
    tokyo    = "ap-northeast-1"
    virginia = "us-east-1"
  }
}

variable "domain" {
  default = "poac.pm"
}

variable "comment" {}

variable "s3_objects" {
  default = [
    "index",
    "error",
  ]
}

data "aws_acm_certificate" "acm" {
  provider = "aws.us-east-1"
  domain   = "*.${var.domain}"
}
data "aws_acm_certificate" "acm" {
  provider = "aws.us-east-1"
  domain   = "*.${var.domain}"
}
