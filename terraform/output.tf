output "vpc-id" {
  value = "${aws_vpc.main.cidr_block}"
}
output "subnet-id-priv1" {
  value = "${aws_subnet.priv1.cidr_block}"
}
output "subnet-id-priv2" {
  value = "${aws_subnet.priv2.cidr_block}"
}
output "subnet-id-pub3" {
  value = "${aws_subnet.pub3.cidr_block}"
}
output "subnet-id-pub4" {
  value = "${aws_subnet.pub4.cidr_block}"
}
output "es-endpoint" {
  value = "${aws_elasticsearch_domain.es.endpoint}"
}

output "COMMENT" {
  value = "Please write VPC-ID(networkID) and Subnet-ID to k8s/cluster.yaml"
}

