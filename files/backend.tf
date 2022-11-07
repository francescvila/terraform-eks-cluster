#
# Storing The State In A Remote Backend
#

terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "state-bucket-value"
    key     = "terraform/tfsate"
    profile = "sandbox"
    encrypt = true
  }
}