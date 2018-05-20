#########################################
# VPC
#########################################
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags {
    Name = "poacpm"
  }
}
#########################################
# Internet gateway
#########################################
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}
#########################################
# NAT gateway
#########################################
resource "aws_eip" "nat" {
    vpc = true
}
resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.pub4.id}"
}
#########################################
# Subnet
#########################################
resource "aws_subnet" "priv1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.regions["tokyo"]}a"
  tags {
    Name = "poacpm-priv1"
  }
}
resource "aws_subnet" "priv2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.regions["tokyo"]}c"
  tags {
    Name = "poacpm-priv2"
  }
}
resource "aws_subnet" "pub3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.regions["tokyo"]}a"
  tags {
    Name = "poacpm-pub3"
  }
}
resource "aws_subnet" "pub4" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.regions["tokyo"]}c"
  tags {
    Name = "poacpm-pub4"
  }
}
#########################################
# Route table
#########################################
resource "aws_route_table" "priv" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.main.id}"
  }
  tags {
    Name = "priv"
  }
}
resource "aws_route_table" "pub" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
  tags {
    Name = "pub"
  }
}
########################################
# Associate subnet and route table
########################################
resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.priv1.id}"
  route_table_id = "${aws_route_table.priv.id}"
}
resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.priv2.id}"
  route_table_id = "${aws_route_table.priv.id}"
}
resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.pub3.id}"
  route_table_id = "${aws_route_table.pub.id}"
}
resource "aws_route_table_association" "d" {
  subnet_id      = "${aws_subnet.pub4.id}"
  route_table_id = "${aws_route_table.pub.id}"
}
########################################
# vpc endpoint
########################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.${var.regions["tokyo"]}.s3"
  route_table_ids = ["${aws_route_table.priv.id}"]
}
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.${var.regions["tokyo"]}.dynamodb"
  route_table_ids = ["${aws_route_table.priv.id}"]
}
