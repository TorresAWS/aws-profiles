output "aws-acm-certificate-domain-arn" {
  description = ""
  value       = aws_acm_certificate.domain.arn 
}

output "example" {
  value = "Remember to enter the AWS account that owns the domain, copy the dns from the hosted zone, paste in the domain dns and then go to certificates and approve the record creation"
}
