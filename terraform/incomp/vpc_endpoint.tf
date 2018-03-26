resource "aws_vpc_endpoint" "s3" {
  vpc_id = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.${regions["tokyo"]}.s3"
  route_table_ids = ["${aws_route_table.public.id}", "${aws_route_table.private.id}"]
}
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.${regions["tokyo"]}.dynamodb"
  route_table_ids = ["${aws_route_table.public.id}", "${aws_route_table.private.id}"]
}
