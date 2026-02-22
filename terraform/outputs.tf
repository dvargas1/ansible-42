output "ansible_inventory" {
  description = "Ansible inventory in YAML format"
  value = yamlencode({
    inception_hosts = {
      hosts = {
        inception_vm = {
          ansible_host            = mgc_network_public_ips.inception_public_ip.public_ip
          ansible_user            = "ubuntu"
          ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
          domain                  = local.full_domain
        }
      }
    }
  })
}

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
