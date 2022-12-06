module "iam_password_policy" {
  source  = "ptonini/iam-account-password-policy/aws"
  version = "~> 1.0.0"
  providers = {
    aws = aws
  }
}

module "cloudtrail" {
  source               = "ptonini/cloudtrail/aws"
  version              = "~> 1.0.0"
  name                 = "audit_logs"
  bucket_name          = "${var.bucket_name_prefix}-${var.account_name}-audit-logs"
  account_id           = var.account_id
  force_destroy_bucket = var.force_destroy_buckets
  providers = {
    aws = aws
  }
}

module "s3_inventory_bucket" {
  source  = "ptonini/s3-bucket/aws"
  version = "~> 1.0.0"
  name    = "${var.bucket_name_prefix}-${var.account_name}-s3-inventories"
  bucket_policy_statements = [
    {
      Sid    = "InventoryPolicy"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "s3:PutObject"
      Resource = [
        "arn:aws:s3:::${var.bucket_name_prefix}-${var.account_name}-s3-inventories/*"
      ]
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "arn:aws:s3:::*"
        },
        StringEquals = {
          "aws:SourceAccount" = var.account_id
          "s3:x-amz-acl"      = "bucket-owner-full-control"
        }
      }
    }
  ]
  force_destroy = true
  providers = {
    aws = aws
  }
}