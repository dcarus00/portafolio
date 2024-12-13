variable "backup_bucket_name" {
  description = "Nombre del bucket S3 para backups"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "production"
}

variable "allowed_ips" {
  description = "IPs permitidas para acceso a servicios"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Cambiar en producción
}
