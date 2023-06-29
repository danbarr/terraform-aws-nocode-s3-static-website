terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      environment = var.env
      department  = var.department
      application = "HashiCafe website"
    }
  }
}

locals {
  timestamp = timestamp()
}

resource "random_integer" "product" {
  min = 0
  max = length(var.hashi_products) - 1
  keepers = {
    "timestamp" = local.timestamp
  }
}

resource "aws_s3_bucket" "www_bucket" {
  bucket_prefix = "${var.prefix}-hashicafe-website-${lower(var.env)}-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [
    aws_s3_bucket_policy.www_bucket,
    aws_s3_bucket_public_access_block.www_bucket
  ]
}

resource "aws_s3_bucket_policy" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.s3_public_access_policy.json

  depends_on = [aws_s3_bucket_public_access_block.www_bucket]
}

data "aws_iam_policy_document" "s3_public_access_policy" {
  statement {
    sid     = "PublicAccess"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.www_bucket.arn}/*"]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "index" {
  key    = "index.html"
  bucket = aws_s3_bucket.www_bucket.id
  content = templatefile("${path.module}/files/index.html", {
    product_name  = var.hashi_products[random_integer.product.result].name
    product_color = var.hashi_products[random_integer.product.result].color
    product_image = var.hashi_products[random_integer.product.result].image_file
  })
  content_type = "text/html"
}

resource "aws_s3_object" "images" {
  for_each     = fileset("${path.module}/files/img/", "*.png")
  bucket       = aws_s3_bucket.www_bucket.id
  key          = "img/${each.value}"
  source       = "${path.module}/files/img/${each.value}"
  content_type = "image/png"
}
