resource "aws_subnet" "priv1" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.regions["tokyo"]}a"
  tags {
    Name = "poacpm-priv1"
  }
}
resource "aws_subnet" "priv2" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.regions["tokyo"]}c"
  tags {
    Name = "poacpm-priv2"
  }
}
resource "aws_subnet" "pub3" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.regions["tokyo"]}a"
  tags {
    Name = "poacpm-pub3"
  }
}
resource "aws_subnet" "pub4" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.regions["tokyo"]}c"
  tags {
    Name = "poacpm-pub4"
  }
}
