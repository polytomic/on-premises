module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  for_each = toset([
    local.polytomic_execution_bucket,
    local.polytomic_export_bucket,
    local.polytomic_artifact_bucket
  ])

  bucket = "${var.prefix}-${each.key}"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = var.tags
}
