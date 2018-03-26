resource "aws_s3_bucket" "k8s" {
  bucket    = "k8s.${var.domain}"
  acl       = "private"
  tags {
    Project = "poacpm"
  }
}
resource "aws_s3_bucket" "secret" {
  bucket    = "secret.${var.domain}"
  acl       = "private"
  tags {
    Project = "poacpm"
  }
}

data "aws_iam_policy_document" "s3" {
  statement {
    sid    = "AddPerm"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::re.${var.domain}/*",
    ]

    principals = {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.cf.iam_arn}"]
    }
  }
}
resource "aws_s3_bucket" "repo" {
  bucket    = "re.${var.domain}"
  acl       = "public-read"
  policy        = "${data.aws_iam_policy_document.s3.json}"
}
