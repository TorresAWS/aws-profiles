data "terraform_remote_state" "zone" {
   backend = "s3"
   config = {
        key = "vpcs/zone/zone.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
        bucket  = "tfstate04022025"
   }
}
