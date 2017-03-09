variable "primary_domain" {
  type = "string"
}

variable "alias_records" {
  type = "list"
}

variable "cloudfront_domain" {
  type = "string"
}

variable "cloudfront_hosted_zone_id" {
  type = "string"
}

output "nameservers" {
  value = "${aws_route53_zone.primary.name_servers}"
}

resource "aws_route53_zone" "primary" {
  name = "${var.primary_domain}"
}

resource "aws_route53_record" "alias" {
  count = "${length(var.alias_records)}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "${element(var.alias_records, count.index)}."
  type = "A"

  alias {
    name = "${var.cloudfront_domain}"
    zone_id = "${var.cloudfront_hosted_zone_id}"
    evaluate_target_health = false
  }
}
