resource "aws_dynamodb_table" "terraform_locks" {
        provider        =  aws.Infrastructure
        name            =  local.aws_s3_bucket_bucket 
        billing_mode    =  local.aws_dynamodb_table_billing_mode
        hash_key        =  local.aws_dynamodb_table_hash_key 
        attribute {
                name    = local.aws_dynamodb_table_attribute_name 
                type    = local.aws_dynamodb_table_attribute_type
        }
}
