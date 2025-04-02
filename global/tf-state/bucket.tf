resource "aws_s3_bucket" "terraform_state" {
  provider        =  aws.Infrastructure
  bucket          =  local.aws_s3_bucket_bucket 
  lifecycle {
    prevent_destroy = true 
  }
}
