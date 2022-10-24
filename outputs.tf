output "endpoint" {
  description = "URL endpoint of the website."
  value       = "http://${aws_s3_bucket_website_configuration.www_bucket.website_endpoint}"
}

output "product" {
  description = "The product which was randomly selected."
  value       = var.hashi_products[random_integer.product.result].name
}
