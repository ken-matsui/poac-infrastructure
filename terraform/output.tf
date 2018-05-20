output "vpc-id" {
  value = "${aws_vpc.main.id}"
}
output "subnet-id-priv1" {
  value = "${aws_subnet.priv1.id}"
}
output "subnet-id-priv2" {
  value = "${aws_subnet.priv2.id}"
}
output "subnet-id-pub3" {
  value = "${aws_subnet.pub3.id}"
}
output "subnet-id-pub4" {
  value = "${aws_subnet.pub4.id}"
}
output "es-endpoint" {
  value = "${aws_elasticsearch_domain.es.endpoint}"
}

output "COMMENT" {
  value = "Please write VPC-ID(networkID) and Subnet-ID to k8s/cluster.yaml"
}

