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
  value = "${module.website_dns.nameservers}"
}

output "cdn_primary_endpoint" {
  value = "${module.website_cdn_primary.domain_name}"
}

output "cdn_redirect_endpoint" {
  value = "${module.website_cdn_redirects.domain_name}"
}


provider "aws" {
  region = "us-west-2"
}

module "website_bucket" {
  source = "github.com/jbgo/terraform-modules//s3-website-bucket"
  primary_domain = "${var.primary_domain}"
}

module "website_cdn_primary" {
  source = "github.com/jbgo/terraform-modules//s3-website-cloudfront"
  bucket_domain = "${module.website_bucket.bucket_domain}"
  alias_domains = ["${var.primary_domain}"]
}

module "website_cdn_redirects" {
  source = "github.com/jbgo/terraform-modules//s3-website-cloudfront"
  bucket_domain = "${module.website_bucket.bucket_domain}"
  redirect_to_primary = true
  alias_domains = "${var.redirect_domains}"
}

module "website_dns" {
  source = "github.com/jbgo/terraform-modules//s3-website-route53"

  zones = "${var.route53_zones}"
  primary_domain = "${var.primary_domain}"

  primary_distribution_domain = "${module.website_cdn_primary.domain_name}"
  primary_distribution_zone_id = "${module.website_cdn_primary.hosted_zone_id}"

  redirect_distribution_domain = "${module.website_cdn_redirects.domain_name}"
  redirect_distribution_zone_id = "${module.website_cdn_redirects.hosted_zone_id}"
}
