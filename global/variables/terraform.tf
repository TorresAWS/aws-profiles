terraform {
    backend "s3" {
        key = "global/variables/variables.tfstate"
        region = "us-east-1"
        profile  = "Infrastructure"
    }
}
