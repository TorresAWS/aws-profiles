resource "aws_s3_bucket_versioning" "terraform_state" {
    provider        =  aws.Infrastructure
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
      status = "Enabled"
    }
}
