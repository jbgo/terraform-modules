variable "aws_region" {
  default = "us-west-2"
}

variable "primary_domain" {
  type = "string"
}

variable "redirect_domains" {
  default = []
}

output "nameservers" {
  value = "${module.s3_website_route53.nameservers}"
}

provider "aws" {
  region = "${var.aws_region}"
}

module "s3_website_bucket" {
  source = "../s3-website-bucket"
  primary_domain = "${var.primary_domain}"
}

module "s3_website_cloudfront" {
  source = "../s3-website-cloudfront"
  bucket_domain = "${module.s3_website_bucket.bucket_domain}"
  primary_domain = "${var.primary_domain}"
  redirect_domains = "${var.redirect_domains}"
}

module "s3_website_route53" {
  source = "../s3-website-route53"
  primary_domain = "${var.primary_domain}"
  alias_records = "${concat(list(var.primary_domain), var.redirect_domains)}"
  cloudfront_domain = "${module.s3_website_cloudfront.domain_name}"
  cloudfront_hosted_zone_id = "${module.s3_website_cloudfront.hosted_zone_id}"
}
