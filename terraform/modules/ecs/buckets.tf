module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  for_each = {
    exports    = local.polytomic_export_bucket,
    executions = local.polytomic_execution_bucket,
    artifacts  = local.polytomic_artifact_bucket,
    stats      = local.polytomic_stats_bucket
  }

  bucket = "${var.prefix}-${var.bucket_prefix}${each.key}"
  acl    = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  lifecycle_rule = each.key == "exports" || each.key == "executions" ? [
    {
      id      = each.key
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
        },
      ]

  }] : []

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}
