terraform {
  required_providers {
    mgc = {
      source = "magalucloud/mgc"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "mgc" {
  region  = var.region
  api_key = var.api_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# SSH Key
resource "mgc_ssh_keys" "inception_key" {
  name = "inception-key"
  key  = var.ssh_public_key
}

# Security Group
resource "mgc_network_security_groups" "inception_sg" {
  name        = "inception-security-group"
  description = "Security group for Inception WordPress"
}

resource "mgc_network_security_groups_rules" "allow_ssh" {
  description       = "Allow SSH access"
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.inception_sg.id
}

resource "mgc_network_security_groups_rules" "allow_http" {
  description       = "Allow HTTP traffic"
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.inception_sg.id
}

resource "mgc_network_security_groups_rules" "allow_https" {
  description       = "Allow HTTPS traffic"
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.inception_sg.id
}

# Virtual Machine (default VPC)
resource "mgc_virtual_machine_instances" "inception_vm" {
  name         = "inception-wordpress"
  machine_type = var.machine_type
  image        = "cloud-ubuntu-24.04 LTS"
  ssh_key_name = mgc_ssh_keys.inception_key.name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y python3 python3-pip
  EOF
  )
}

# Get primary interface from the VM
locals {
  primary_interface_id = [
    for interface in mgc_virtual_machine_instances.inception_vm.network_interfaces :
    interface.id if interface.primary
  ][0]

  vpc_id      = var.vpc_id
  full_domain = var.subdomain != "" ? "${var.subdomain}.${var.domain}" : var.domain
}

# Attach Security Group to VM's primary interface
resource "mgc_network_security_groups_attach" "inception_sg_attach" {
  security_group_id = mgc_network_security_groups.inception_sg.id
  interface_id      = local.primary_interface_id
}

# Public IP
resource "mgc_network_public_ips" "inception_public_ip" {
  description = "Inception WordPress public IP"
  vpc_id      = local.vpc_id
}

# Attach Public IP to VM's primary interface
resource "mgc_network_public_ips_attach" "inception_ip_attach" {
  public_ip_id = mgc_network_public_ips.inception_public_ip.id
  interface_id = local.primary_interface_id
}

# Cloudflare DNS - Create A record pointing domain to VM public IP
resource "cloudflare_dns_record" "inception_dns" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  type    = "A"
  content = mgc_network_public_ips.inception_public_ip.public_ip
  ttl     = 300
  proxied = false
  comment = "Inception WordPress - managed by Terraform"
}

# Generate Ansible inventory
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yaml"
  content  = <<-EOF
    inception_hosts:
      hosts:
        inception_vm:
          ansible_host: ${mgc_network_public_ips.inception_public_ip.public_ip}
          ansible_user: ubuntu
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
          domain: ${local.full_domain}
  EOF
}

# Outputs
output "vm_public_ip" {
  description = "Public IP address of the Inception VM"
  value       = mgc_network_public_ips.inception_public_ip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh -o StrictHostKeyChecking=no ubuntu@${mgc_network_public_ips.inception_public_ip.public_ip}"
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "https://${local.full_domain}"
}
