output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.default.id
}

output "instance_name" {
  description = "EC2 instance name"
  value       = "${var.instance_name_prefix}-${random_id.instance_suffix.hex}"
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.default.public_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = aws_instance.default.public_dns
}
