variable "zones" {
  type = "list"
}

variable "primary_domain" {
  default = true
}

variable "primary_distribution_domain" {
  type = "string"
}

variable "primary_distribution_zone_id" {
  type = "string"
}

variable "redirect_distribution_domain" {
  type = "string"
}

variable "redirect_distribution_zone_id" {
  type = "string"
}


output "nameservers" {
  value = "${aws_route53_zone.zone.name_servers}"
}

resource "aws_route53_zone" "zone" {
  count = "${length(var.zones)}"
  name = "${element(var.zones, count.index)}"
}

resource "aws_route53_record" "default" {
  count = "${length(var.zones)}"
  zone_id = "${element(aws_route53_zone.zone.*.zone_id, count.index)}"
  name = "${element(var.zones, count.index)}."
  type = "A"

  alias {
    name = "${element(var.zones, count.index) == var.primary_domain ? var.primary_distribution_domain : var.redirect_distribution_domain}"
    zone_id = "${element(var.zones, count.index) == var.primary_domain ? var.primary_distribution_zone_id : var.redirect_distribution_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  count = "${length(var.zones)}"
  zone_id = "${element(aws_route53_zone.zone.*.zone_id, count.index)}"
  name = "www.${element(var.zones, count.index)}."
  type = "A"

  depends_on = ["aws_route53_zone.zone"]

  alias {
    name = "${format("www.%s", element(var.zones, count.index)) == var.primary_domain ? var.primary_distribution_domain : var.redirect_distribution_domain}"
    zone_id = "${format("www.%s", element(var.zones, count.index)) == var.primary_domain ? var.primary_distribution_zone_id : var.redirect_distribution_zone_id}"
    evaluate_target_health = false
  }
}
