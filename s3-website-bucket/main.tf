variable "primary_domain" {
  type = "string"
}

variable "index_document" {
  default = "index.html"
}

variable "error_document" {
  default = "index.html"
}

output "bucket_domain" {
  value = "${aws_s3_bucket.website_bucket.bucket_domain_name}"
}

output "website_url" {
  value = "${aws_s3_bucket.website_bucket.website_endpoint}"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.primary_domain}"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.website_bucket_policy.json}"

  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
  }
}

data "aws_iam_policy_document" "website_bucket_policy" {
  statement = {
    sid = "1"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = ["arn:aws:s3:::${var.primary_domain}/*"]
  }
}
