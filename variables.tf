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