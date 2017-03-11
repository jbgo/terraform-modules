variable "bucket_domain" {
  type = "string"
}

variable "alias_domains" {
  type = "list"
}

variable "https_mode" {
  default = "redirect-to-https"
}

variable "redirect_to_primary" {
  default = false
}

output "domain_name" {
  value = "${aws_cloudfront_distribution.website.domain_name}"
}

output "hosted_zone_id" {
  value = "${aws_cloudfront_distribution.website.hosted_zone_id}"
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "${var.bucket_domain}${var.redirect_to_primary ? "/_s3_website_redirect" : ""}"
}

resource "aws_cloudfront_distribution" "website" {
  origin {
    domain_name = "${var.bucket_domain}"
    origin_id = "${aws_cloudfront_origin_access_identity.website.id}"
    origin_path = "${var.redirect_to_primary ? "/_s3_website_redirect" : ""}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = "${var.alias_domains}"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    compress = true
    target_origin_id = "${aws_cloudfront_origin_access_identity.website.id}"

    min_ttl = 60
    default_ttl = 3600
    max_ttl = 86400

    forwarded_values {
      cookies { forward = "none" }
      query_string = false
    }

    viewer_protocol_policy = "${var.https_mode}"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
