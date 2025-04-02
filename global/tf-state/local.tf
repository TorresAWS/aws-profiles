locals {
   aws_s3_bucket_lifecycle_prevent_destroy = true
   aws_dynamodb_table_billing_mode         = "PAY_PER_REQUEST" 
   aws_dynamodb_table_hash_key             = "LockID" 
   aws_dynamodb_table_attribute_name       = "LockID" 
   aws_dynamodb_table_attribute_type       = "S" 
   backend_region                          = "us-east-1"
   backend_encrypt                         = "true"
}
