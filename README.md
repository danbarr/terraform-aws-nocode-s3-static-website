# Terraform module aws-nocode-s3-static-website

Provisions an S3 bucket configured for static website hosting, with a sample HashiCafe site.

Enabled for Terraform Cloud [no-code provisioning](https://developer.hashicorp.com/terraform/cloud-docs/no-code-provisioning/module-design).

This demo uses HashiCorp Vault's [AWS secrets engine](https://developer.hashicorp.com/vault/docs/secrets/aws) to provide temporary AWS credentials for provisioning. For simplicity, the [`userpass` auth method](https://developer.hashicorp.com/vault/docs/auth/userpass) is used. The Vault server and namespace (if required) must be supplied to the workspace with the `VAULT_ADDR` and `VAULT_NAMESPACE` environment variables.
