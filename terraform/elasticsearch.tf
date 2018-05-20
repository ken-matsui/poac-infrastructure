resource "aws_elasticsearch_domain" "es" {
  domain_name           = "poacpm"
  elasticsearch_version = "6.2"
  cluster_config {
    instance_type  = "t2.small.elasticsearch"
    instance_count = 1
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  vpc_options {
    subnet_ids = ["${aws_subnet.pub4.id}"]
  }

# Full access (Only within the same vpc)
  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:ap-northeast-1:${data.aws_caller_identity.self.account_id}:domain/${aws_elasticsearch_domain.es.domain_id}/*"
    }
  ]
}
CONFIG
}
