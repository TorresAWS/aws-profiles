resource "local_file" "create-backend-file" {
    content  = <<EOF
bucket         = "${local.aws_s3_bucket_bucket}" 
dynamodb_table = "${local.aws_s3_bucket_bucket}" 
region         = "us-east-1"
encrypt        = "true"
    EOF
    filename = "../../global/tf-state/backend.hcl"
}
