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

  # vpc_options {
  #   security_group_ids =
  #   subnet_ids =
  # }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow"
        }
    ]
}
CONFIG
}
