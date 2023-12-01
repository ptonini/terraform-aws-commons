variable "bucket_name_prefix" {}

variable "force_destroy_buckets" {
  default = false
}

variable "ssh_master_key" {
  type = object({
    key_name   = string
    public_key = string
  })
  default = null
}

variable "s3_encryption_key" {
  type = object({
    enable_key_rotation     = optional(bool, true)
    deletion_window_in_days = optional(number, 10)
  })
  default = {}
}

variable "cloudwatch_encryption_key" {
  type = object({
    enable_key_rotation     = optional(bool, true)
    deletion_window_in_days = optional(number, 10)
  })
  default = {}
}