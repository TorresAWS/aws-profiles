resource "aws_acm_certificate" "domain" {
  provider                     =  aws.Infrastructure
  domain_name       = "${data.terraform_remote_state.variables.outputs.domain}"
  validation_method = "DNS"
  subject_alternative_names = ["www.${data.terraform_remote_state.variables.outputs.domain}"]
  lifecycle {
    create_before_destroy = true
  }
}
