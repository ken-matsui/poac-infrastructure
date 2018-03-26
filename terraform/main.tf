provider "aws" {
  region = "${var.region["tokyo"]}"
}
provider "aws" {
  alias  = "us-east-1"
  region = "${var.regions["virginia"]}"
}
