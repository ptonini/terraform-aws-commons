output "ssh_master_key" {
  value = one(aws_key_pair.this)
}

output "s3_kms_key_arn" {
  value = module.kms_key_s3.this.arn
}

output "cloudwatch_kms_key_id" {
  value = module.kms_key_cloudwatch.this.arn
}

output "s3_inventory_bucket_arn" {
  value = module.s3_inventory_bucket.this.arn
}

output "s3_access_log_bucket_arn" {
  value = module.s3_access_log_bucket.this.arn
}