# data "aws_acm_certificate" "acm" {
#   provider = "aws.tokyo"
#   domain = "${var.domain}"
# }
data "aws_acm_certificate" "acm" {
  provider = "aws.virginia"
  domain = "*.${var.domain}"
}
