resource "aws_s3_bucket" "s3" {
  bucket = "repo.poac.pm"
  acl    = "private"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.poacpm.bucket_domain_name}"
    origin_id   = "S3-repo.poac.pm"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"

  logging_config {
    include_cookies = false
    bucket          = "logs.poac.pm.s3.amazonaws.com"
    prefix          = "myprefix"
  }

  aliases = ["repo.poac.pm"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-repo.poac.pm"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:ap-northeast-1:308453953340:certificate/9a447820-5a69-4c13-8ebe-dc9fb0e90104"
    cloudfront_default_certificate = true
  }
}
