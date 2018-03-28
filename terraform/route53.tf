resource "aws_route53_zone" "poacpm" {
  name = "poac.pm"
}

resource "aws_route53_record" "poacpm-a" {
  zone_id = "${aws_route53_zone.poacpm.zone_id}"
  name    = "${aws_s3_bucket.repo.id}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cf.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cf.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "k8s" {
  name = "k8s.poac.pm"
}

resource "aws_route53_record" "k8s-ns" {
  zone_id = "${aws_route53_zone.poacpm.zone_id}"
  name    = "k8s.poac.pm"
  type    = "NS"
  ttl     = "300"

  records = [
    "${aws_route53_zone.k8s.name_servers.0}",
    "${aws_route53_zone.k8s.name_servers.1}",
    "${aws_route53_zone.k8s.name_servers.2}",
    "${aws_route53_zone.k8s.name_servers.3}",
  ]
}
