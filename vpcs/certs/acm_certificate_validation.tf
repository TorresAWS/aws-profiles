resource "aws_acm_certificate_validation" "cert-validation" {
  provider                     =  aws.Infrastructure
  certificate_arn         = aws_acm_certificate.domain.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation-record : record.fqdn]
  timeouts {
    create = "20m"
  }
}
