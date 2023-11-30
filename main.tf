data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description             = var.s3_encryption_key.description
  deletion_window_in_days = var.s3_encryption_key.deletion_window_in_days
  enable_key_rotation     = var.s3_encryption_key.enable_key_rotation
}

resource "aws_key_pair" "this" {
  count      = var.ssh_master_key == null ? 0 : 1
  key_name   = var.ssh_master_key.key_name
  public_key = var.ssh_master_key.public_key
}

resource "aws_ec2_serial_console_access" "this" {
  enabled = true
}

module "iam_password_policy" {
  source  = "ptonini/iam-account-password-policy/aws"
  version = "~> 1.0.0"
}

module "cloudtrail" {
  source               = "ptonini/cloudtrail/aws"
  version              = "~> 1.1.1"
  name                 = "audit-logs"
  bucket_name          = "${var.bucket_name_prefix}-audit-logs"
  bucket_kms_key_id    = aws_kms_key.this.id
  account_id           = data.aws_caller_identity.current.account_id
  force_destroy_bucket = var.force_destroy_buckets
}

module "s3_inventory_bucket" {
  source  = "ptonini/s3-bucket/aws"
  version = "~> 2.2.0"
  name    = "${var.bucket_name_prefix}-s3-inventories"
  server_side_encryption = {
    kms_master_key_id = aws_kms_key.this.id
  }
  bucket_policy_statements = [
    {
      Sid    = "InventoryPolicy"
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "s3:PutObject"
      Resource = [
        "arn:aws:s3:::${var.bucket_name_prefix}-s3-inventories/*"
      ]
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "arn:aws:s3:::*"
        },
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          "s3:x-amz-acl"      = "bucket-owner-full-control"
        }
      }
    }
  ]
  force_destroy = var.force_destroy_buckets
}

module "s3_access_log_bucket" {
  source  = "ptonini/s3-bucket/aws"
  version = "~> 2.2.0"
  name    = "${var.bucket_name_prefix}-s3-access-log"
  server_side_encryption = {
    kms_master_key_id = aws_kms_key.this.id
  }
  bucket_policy_statements = [
    {
      Sid    = "S3ServerAccessLogsPolicy"
      Effect = "Allow"
      Principal = {
        Service = "logging.s3.amazonaws.com"
      }
      Action = "s3:PutObject"
      Resource = [
        "arn:aws:s3:::${var.bucket_name_prefix}-s3-access-log/*"
      ]
      Condition = {
        ArnLike = {
          "aws:SourceArn" = "arn:aws:s3:::*"
        },
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }
  ]
  force_destroy = var.force_destroy_buckets
}