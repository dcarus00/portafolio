output "vpc_id" {
  value = aws_vpc.devsecops_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "backup_bucket_name" {
  value = aws_s3_bucket.backups.id
}
