variable "primary_domain" {
  default = "example.com"
}

variable "redirect_domains" {
  default = [
    "example.org",
    "example.net",
    "example.co.uk",
    "www.example.com",
    "www.example.org",
    "www.example.net",
    "www.example.co.uk"
  ]
}

variable "route53_zones" {
  default = [
    "example.com",
    "example.org",
    "example.net",
    "example.co.uk",
  ]
}

output "nameservers" {
  value = "${module.s3_website_route53.nameservers}"
}

provider "aws" {
  region = "us-west-2"
}

module "s3_website_bucket" {
  source = "github.com/jbgo/terraform-modules//s3-website-bucket"
  primary_domain = "${var.primary_domain}"
}

module "s3_website_cloudfront" {
  source = "github.com/jbgo/terraform-modules//s3-website-cloudfront"
  bucket_domain = "${module.s3_website_bucket.bucket_domain}"
  alias_domains = ["${var.primary_domain}"]
}

module "s3_website_cloudfront_redirect" {
  source = "github.com/jbgo/terraform-modules//s3-website-cloudfront"
  bucket_domain = "${module.s3_website_bucket.bucket_domain}"
  redirect_to_primary = true
  alias_domains = "${var.redirect_domains}"
}

module "s3_website_route53" {
  source = "github.com/jbgo/terraform-modules//s3-website-route53"

  zones = "${var.route53_zones}"
  primary_domain = "${var.primary_domain}"

  primary_distribution_domain = "${module.s3_website_cloudfront.domain_name}"
  primary_distribution_zone_id = "${module.s3_website_cloudfront.hosted_zone_id}"

  redirect_distribution_domain = "${module.s3_website_cloudfront_redirect.domain_name}"
  redirect_distribution_zone_id = "${module.s3_website_cloudfront_redirect.hosted_zone_id}"
}
