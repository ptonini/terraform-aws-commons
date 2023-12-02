output "ssh_master_key" {
  value = one(aws_key_pair.this)
}

output "s3_kms_key_arn" {
  value = aws_kms_key.s3_encryption.arn
}

output "cloudwatch_kms_key_id" {
  value = aws_kms_key.cloudwatch_encryption.id
}

output "s3_inventory_bucket_arn" {
  value = module.s3_inventory_bucket.this.arn
}

output "s3_access_log_bucket_arn" {
  value = module.s3_access_log_bucket.this.arn
}