<<<<<<< HEAD
resource "local_file" "exportbackend-to-vpc-zone" {
    content  = <<EOF
variable "backendname" {
# domain name
# This should be your own domain hosted in AWS (e.g. mydomain.com)
  default = "${local.aws_s3_bucket_bucket}"   # Make sure you change this name
=======
resource "local_file" "exportbackend-to-global-variables" {
    content  = <<EOF
variable "backendname" {
  default = "${local.aws_s3_bucket_bucket}"   
>>>>>>> 5df2590 (add backend with a single variable)
}
    EOF
    filename = "../../global/variables/backendname-var.tf"
}
