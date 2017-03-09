variable "bucket_domain" {
  type = "string"
}

variable "primary_domain" {
  type = "string"
}

variable "redirect_domains" {
  default = []
}

variable "require_https" {
  default = true
}

output "domain_name" {
  value = "${aws_cloudfront_distribution.website.domain_name}"
}

output "hosted_zone_id" {
  value = "${aws_cloudfront_distribution.website.hosted_zone_id}"
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "${var.primary_domain}"
}

resource "aws_cloudfront_distribution" "website" {
  # You can have 1 or more origins
  origin {
    domain_name = "${var.bucket_domain}"
    origin_id = "${aws_cloudfront_origin_access_identity.website.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = "${concat(list(var.primary_domain), var.redirect_domains)}"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    compress = true
    # When you have multiple origins, this is how you map a cache behavior to an origin.
    target_origin_id = "${aws_cloudfront_origin_access_identity.website.id}"

    min_ttl = 60
    default_ttl = 3600
    max_ttl = 86400

    # For static sites you don't really care,
    # but for dynamic site, especially those with authentication,
    # you will want to carefully understand these.
    forwarded_values {
      cookies { forward = "none" }
      query_string = false
    }

    viewer_protocol_policy = "${var.require_https ? "redirect-to-https" : "allow-all"}"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL certificate settings
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
