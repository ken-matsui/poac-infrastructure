resource "aws_cloudfront_origin_access_identity" "cf" {
  comment = "${var.name}-cf"
}

resource "aws_cloudfront_distribution" "cf" {
  comment             = "${var.name}-cf"
  price_class         = "PriceClass_200"
  aliases             = ["${aws_s3_bucket.repo.id}"]
  enabled             = true

  origin {
    domain_name = "${aws_s3_bucket.repo.id}.s3.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.repo.id}"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.cf.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.repo.id}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    max_ttl                = 31536000
    default_ttl            = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${data.aws_acm_certificate.acm.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
