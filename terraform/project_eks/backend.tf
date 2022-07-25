terraform {
  backend "s3" {
    bucket = "tfstate-project-genesis-eks"
    key    = "genesis/eks.tfstate"
    region = "us-east-1"
  }
}