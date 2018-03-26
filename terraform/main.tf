provider "aws" {
  region = "ap-northeast-1"
  alias  = "tokyo"
}
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
