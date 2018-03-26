data "aws_acm_certificate" "acm" {
  domain = "${var.domain}"
}
data "aws_acm_certificate" "acm" {
  domain = "*.${var.domain}"
}
