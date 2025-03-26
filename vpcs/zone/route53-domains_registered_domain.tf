resource "aws_route53domains_registered_domain" "this" {
  provider     =  aws.Domain
  domain_name = "${data.terraform_remote_state.variables.outputs.domain}" 
  dynamic "name_server" {
    for_each = toset(aws_route53_zone.domain.name_servers)
    content{
       name = name_server.value
    }
  }
  lifecycle {
     prevent_destroy = true
  }
  depends_on = [
    aws_route53_zone.domain 
  ]
}
