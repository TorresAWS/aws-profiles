resource "aws_route53_zone" "domain" {
  provider     =  aws.Domain
  name         = "${data.terraform_remote_state.variables.outputs.domain}" 

}


