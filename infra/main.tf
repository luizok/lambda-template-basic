provider "aws" {
  default_tags {
    tags = {
      project = var.lambda-name
    }
  }
}

provider "archive" {}
provider "null" {}

terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
