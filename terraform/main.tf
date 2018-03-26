provider "aws" {
  region = "${var.regions["tokyo"]}"
  alias  = "tokyo"
}
provider "aws" {
  region = "${var.regions["virginia"]}"
  alias  = "virginia"
}
