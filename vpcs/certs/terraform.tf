terraform {
    backend "s3" {
        key = "vpcs/certs/certs.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
   }
}
