# Terraform Modules

A collection of potentially reusable [Terraform](https://www.terraform.io/) modules for common AWS patterns.

## Index

* [AWS S3 Static Websites](#aws-s3-static-websites)
  * [s3-website-bucket module](#s3-website-bucket-module)
  * [s3-website-cloudfront module](#s3-website-cloudfront-module)
  * [s3-website-route53 module](#s3-website-route53-module)

## AWS S3 Static Websites

The `s3-website-*` modules provide everything required to configure a cost-efficent [static website with AWS S3](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html). You can combine these modules for a complete static website hosting solution, including CDN with and DNS, or you can use the modules à la carte if you are already using another provider for CDN and DNS, such as CloudFlare.

### Usage

See [examples/s3-website/main.tf](examples/s3-website/main.tf) for a complete example.

### s3-website-bucket module

Creates and configures an S3 bucket to host a static website. As part of the configuration, the s3-website-bucket module creates a [redirect rule](http://docs.aws.amazon.com/AmazonS3/latest/dev/how-to-page-redirect.html) that will 301 redirect requests from `/_s3_website_redirect/<path>` to `https://<primary_domain>/<path>`. This is used by the `s3-website-cloudfront` module in order to setup redirects from multiple domains (such as `.net`, `.org`, and `www.`) to the canonical domain without having to create a separate bucket for each domain.

#### Variables

| name | type | description | required | default |
|------|------|-------------|----------|---------|
| primary_domain | string | primary (or canonical) domain of your website | yes | |
| index_document | string | the [default page](http://docs.aws.amazon.com/AmazonS3/latest/dev/IndexDocumentSupport.html) returned when the request path ends with `/` | no | index.html |
| error_document | string | a [custom error page](http://docs.aws.amazon.com/AmazonS3/latest/dev/CustomErrorDocSupport.html) to show instead of the AWS S3 default error page | no | index.html |

#### Outputs

| name | type | description |
|------|------|-------------|
| website_endpoint | string | the [S3 endpoint](http://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteEndpoints.html) for your bucket website |

### s3-website-cloudfront module

Creates a CloudFront distributions configured to use the S3 bucket website identified by the `bucket_domain` variable as its origin.

#### Variables

| name | type | description | required | default |
|------|------|-------------|----------|---------|
| website_endpoint | string | the S3 endpoint of your bucket website | yes | |
| alias_domains | list | a list of custom domains that | yes | |
| https_mode | string | the [viewer protocol policy]() for this cloudfront distribution | no | redirect-to-https |
| redirect_to_primary | bool | whether the alias_domains should redirect to the primary (canonical) domain* | no | false |

*When `redirect_to_primary` is set to true, the distribution will use `/_s3_website_redirect` as the [origin path](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-values-specify.html#DownloadDistValuesOriginPath). If used in combination with the `s3-website-bucket` module, this will result in any request to any of the alias domains referenced in this distribution to redirect to the `primary_domain` configured for the S3 bucket website.

#### Outputs

| name | type | description |
|------|------|-------------|
| domain_name | string | the cloudfront distribution endpoint |
| hosted_zone_id | string | the route53 zone ID for the cloudfront distribution |

### s3-website-route53 module

Creates the DNS configuration required to use custom domains for your cloudfront distributions by creating route53 zones and record sets. Assuming you have created two cloudfront distributions and s3 website redirect rules using the `s3-website-cloudfront` and `s3-website-bucket` modules as shown in [examples/s3-website/main.tf](examples/s3-website/main.tf), this module will set up the DNS records to point to the appropriate CloudFront distribution (primary or redirect) for the given domains. If you are already hosting DNS for your site elsewhere, or even if you already have a hosted zone and record sets configured with route53, this module will likely not be useful to you. If however, you are setting up a new site from scratch, this module can save you the effort of configuring DNS manually.

__NOTE:__ this module does not register a domain or configure your nameservers. You will need to register the domain yourself using any domain registrar. You will also need to use your registrar's interface to update the nameservers for your domain to match the `nameservers` output of this module.

#### Variables

| name | type | description | required | default |
|------|------|-------------|----------|---------|
| zones | list | a list of domains to create route53 hosted zones for | yes | |
| primary_domain | string | the primary domain of your website | yes | |
| primary_distribution_domain | string | the cloudfront distribution domain of your primary distribution | yes | |
| primary_distribution_zone_id | string | the cloudfront distribution hosted zone id of your primary distribution | yes | |
| redirect_distribution_domain | string | the cloudfront distribution domain of your redirect distribution | yes | |
| redirect_distribution_zone_id | string | the cloudfront distribution hosted zone id of your redirect distribution | yes | |

#### Outputs

| name | type | description |
|------|------|-------------|
| nameservers | list | a list of nameservers to configure in your custom domains' whois records |
