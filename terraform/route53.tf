resource "aws_route53_zone" "poacpm" {
  name = "poac.pm"
}

resource "aws_route53_record" "poacpm" {
  zone_id = "${aws_route53_zone.poacpm.zone_id}"
  name    = "${aws_s3_bucket.repo.id}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cf.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cf.hosted_zone_id}"
    evaluate_target_health = false
  }
}
