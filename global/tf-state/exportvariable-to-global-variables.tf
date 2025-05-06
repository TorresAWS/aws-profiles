resource "local_file" "exportbackend-to-global-variables" {
    content  = <<EOF
variable "backendname" {
  default = "${local.aws_s3_bucket_bucket}"   
}
    EOF
    filename = "../../global/variables/backendname-var.tf"
}
