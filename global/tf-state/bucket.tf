resource "aws_s3_bucket" "terraform_state" {
  provider        =  aws.Infrastructure
  bucket          =  local.aws_s3_bucket_bucket 
<<<<<<< HEAD
<<<<<<< HEAD
  lifecycle {
    prevent_destroy = true 
  }
=======
#  lifecycle {
#    prevent_destroy = true 
#  }
>>>>>>> 5df2590 (add backend with a single variable)
=======
#  lifecycle {
#    prevent_destroy = true 
#  }
>>>>>>> 5df2590c20626653835164556da77d4faa7426fd
}
