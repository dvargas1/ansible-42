variable "api_key" {
  type        = string
  sensitive   = true
  description = "Magalu Cloud API Key"
}

variable "region" {
  type        = string
  default     = "br-se1"
  description = "Magalu Cloud region (br-se1 = Southeast, br-ne1 = Northeast)"
}

variable "machine_type" {
  type        = string
  default     = "BV2-2-40"
  description = "VM machine type (BV1-1-40 = 1vCPU/1GB, BV2-2-40 = 2vCPU/2GB)"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key content for VM access"
}

variable "vpc_id" {
  type        = string
  description = "ID of the default VPC (get from MagaluCloud console: Network > VPCs)"
}

variable "domain" {
  type        = string
  description = "Root domain on Cloudflare (e.g. tupinymquim.com)"
}

variable "subdomain" {
  type        = string
  default     = "cloud"
  description = "Subdomain for WordPress (e.g. 'cloud' creates cloud.tupinymquim.com)"
}

variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token with DNS edit permissions"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID (found on domain overview page)"
}
