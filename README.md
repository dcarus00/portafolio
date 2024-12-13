# 🚀 Infraestructura DevSecOps Automatizada

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue.svg)](https://www.terraform.io/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

# 🚀 Infraestructura DevSecOps Automatizada
## 📄 Descripción

Este proyecto presenta una infraestructura DevSecOps completamente automatizada utilizando Docker Compose y Terraform. La configuración incluye servicios esenciales para el monitoreo, gestión de logs, escaneo de vulnerabilidades y pipelines de CI/CD, desplegados en un entorno seguro en AWS.

## 🔧 Tecnologías Utilizadas

- Docker Compose: Orquestación de contenedores
- Terraform: Infraestructura como código
- AWS: Proveedor de servicios en la nube
- Prometheus & Grafana: Monitoreo y visualización de métricas
- Elasticsearch & Kibana: Gestión y visualización de logs
- Trivy: Escaneo de vulnerabilidades
- Jenkins: Automatización de pipelines de CI/CD

## 📂 Estructura del Proyecto

```
.
├── docker/
│   ├── prometheus/
│   │   └── prometheus.yml
│   ├── blackbox/
│   │   └── blackbox.yml
│   └── backup/
│       └── backup-script.sh
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── scripts/
│   └── restore-backup.sh
├── secrets/
│   └── README.md
├── docker-compose.yml
├── .gitignore
└── README.md
```

## 🚀 Despliegue

### 1. Infraestructura AWS
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Servicios
```bash
docker-compose up -d
```

## 📝 Configuración y Uso

### docker-compose.yml
```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:v2.44.0
    volumes:
      - ./prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - monitoring
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "-q", "--tries=1", "--spider", "http://localhost:9090/-/healthy"]
      interval: 30s
      timeout: 10s
      retries: 3

  grafana:
    image: grafana/grafana:9.5.0
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    volumes:
      - grafana_data:/var/lib/grafana
      - ./certs:/etc/grafana/certs:ro
    networks:
      - monitoring
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_admin_password
      - GF_SERVER_PROTOCOL=https
      - GF_SERVER_CERT_FILE=/etc/grafana/certs/grafana.crt
      - GF_SERVER_KEY_FILE=/etc/grafana/certs/grafana.key
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    restart: unless-stopped
    secrets:
      - grafana_admin_password

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=true
      - ELASTIC_PASSWORD_FILE=/run/secrets/elastic_password
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
      - ./certs:/usr/share/elasticsearch/config/certs:ro
    networks:
      - monitoring
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 2G
        reservations:
          cpus: '0.50'
          memory: 1G
    restart: unless-stopped
    secrets:
      - elastic_password
    ulimits:
      memlock:
        soft: -1
        hard: -1

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    environment:
      - ELASTICSEARCH_PASSWORD_FILE=/run/secrets/elastic_password
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    volumes:
      - ./certs:/usr/share/kibana/config/certs:ro
    networks:
      - monitoring
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 1G
        reservations:
          cpus: '0.25'
          memory: 512M
    restart: unless-stopped
    secrets:
      - elastic_password

  jenkins:
    image: jenkins/jenkins:lts-2.387.1
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - monitoring
    deploy:
      resources:
        limits:
          cpus: '1.00'
          memory: 2G
        reservations:
          cpus: '0.50'
          memory: 1G
    restart: unless-stopped

  certbot:
    image: certbot/certbot:latest
    volumes:
      - ./certs:/etc/letsencrypt
      - ./certbot/www:/var/www/certbot
    command: certonly --webroot -w /var/www/certbot --email ${EMAIL_ADDRESS} -d ${DOMAIN_NAME} --agree-tos
    deploy:
      restart_policy:
        condition: none

  backup:
    image: amazon/aws-cli:latest
    volumes:
      - prometheus_data:/backup/prometheus:ro
      - elasticsearch_data:/backup/elasticsearch:ro
      - grafana_data:/backup/grafana:ro
      - ./backup/backup-script.sh:/backup-script.sh:ro
    environment:
      - AWS_ACCESS_KEY_ID_FILE=/run/secrets/aws_access_key
      - AWS_SECRET_ACCESS_KEY_FILE=/run/secrets/aws_secret_key
      - BACKUP_BUCKET=${BACKUP_BUCKET_NAME}
    entrypoint: ["/backup-script.sh"]
    deploy:
      restart_policy:
        condition: none
    secrets:
      - aws_access_key
      - aws_secret_key

  node-exporter:
    image: prom/node-exporter:latest
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
    networks:
      - monitoring
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring
    restart: unless-stopped

  blackbox-exporter:
    image: prom/blackbox-exporter:latest
    volumes:
      - ./blackbox:/config
    command:
      - '--config.file=/config/blackbox.yml'
    networks:
      - monitoring
    restart: unless-stopped

volumes:
  jenkins_home:
  prometheus_data:
  elasticsearch_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge

secrets:
  grafana_admin_password:
    file: ./secrets/grafana_admin_password.txt
  elastic_password:
    file: ./secrets/elastic_password.txt
  aws_access_key:
    file: ./secrets/aws_access_key.txt
  aws_secret_key:
    file: ./secrets/aws_secret_key.txt
```

### terraform/main.tf
```hcl
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "Región de AWS"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  default     = "10.0.2.0/24"
}

resource "aws_vpc" "devsecops_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "DevSecOps-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devsecops_vpc.id

  tags = {
    Name = "DevSecOps-IGW"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devsecops_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "DevSecOps-Public-Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.devsecops_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "DevSecOps-Private-Subnet"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "DevSecOps-NAT"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devsecops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "DevSecOps-Public-RT"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.devsecops_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "DevSecOps-Private-RT"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security group for monitoring services"
  vpc_id      = aws_vpc.devsecops_vpc.id

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  # Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  # Kibana
  ingress {
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  # Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevSecOps-Monitoring-SG"
  }
}

resource "aws_s3_bucket" "backups" {
  bucket = var.backup_bucket_name

  tags = {
    Name = "DevSecOps-Backups"
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups_lifecycle" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "cleanup_old_backups"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}
```

### terraform/variables.tf
```hcl
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
```

### terraform/outputs.tf
```hcl
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
```

### docker/backup/backup-script.sh
```bash
#!/bin/bash

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"
S3_BUCKET="${BACKUP_BUCKET}"

# Comprimir directorios de datos
cd ${BACKUP_DIR}
for service in prometheus elasticsearch grafana; do
    tar czf "${service}_${TIMESTAMP}.tar.gz" "${service}/"
    aws s3 cp "${service}_${TIMESTAMP}.tar.gz" "s3://${S3_BUCKET}/${service}/"
    rm "${service}_${TIMESTAMP}.tar.gz"

## 🎯 Descripción

Una solución completa y automatizada de infraestructura DevSecOps que integra las mejores prácticas de desarrollo, seguridad y operaciones. Este proyecto proporciona una infraestructura lista para usar que incluye monitoreo, logging, seguridad y CI/CD, todo desplegado en AWS y gestionado con Infrastructure as Code.

## ✨ Características Principales

- **🏗️ Infraestructura como Código**
  - Despliegue automatizado en AWS usando Terraform
  - Configuración de red segura con VPC, subnets públicas y privadas
  - Gestión automatizada de grupos de seguridad

- **📊 Monitoreo y Observabilidad**
  - Stack completo de Prometheus y Grafana
  - Dashboards predefinidos para métricas clave
  - Monitoreo de contenedores con cAdvisor
  - Sistema de alertas configurado

- **📝 Gestión de Logs**
  - Elasticsearch y Kibana para análisis de logs
  - Retención y búsqueda eficiente
  - Dashboards personalizados para visualización

- **🔒 Seguridad**
  - Certificados SSL/TLS automatizados con Certbot
  - Escaneo de vulnerabilidades con Trivy
  - Gestión segura de secretos
  - HTTPS forzado en todos los endpoints

- **🔄 CI/CD**
  - Jenkins preconfigurado con pipeline as code
  - Integración con Docker para builds
  - Flujos de trabajo automatizados

- **💾 Backup y Recuperación**
  - Sistema automatizado de backups a S3
  - Retención configurable
  - Scripts de restauración incluidos

## 🛠️ Stack Tecnológico

- **Infraestructura**: AWS, Terraform
- **Contenedores**: Docker, Docker Compose
- **Monitoreo**: Prometheus, Grafana, Node Exporter, cAdvisor
- **Logs**: Elasticsearch, Kibana
- **CI/CD**: Jenkins
- **Seguridad**: Certbot, Trivy
- **Backup**: AWS S3, AWS CLI

## 📋 Prerequisitos

- AWS CLI configurado
- Docker y Docker Compose
- Terraform >= 1.0.0
- Git

## 🚀 Inicio Rápido

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/infraestructura-devsecops.git
cd infraestructura-devsecops
```

2. **Configurar variables de entorno**
```bash
cp .env.example .env
# Editar .env con tus valores
```

3. **Desplegar infraestructura**
```bash
cd terraform
terraform init
terraform apply

cd ..
docker-compose up -d
```

## 📚 Documentación

La documentación completa está disponible en la [Wiki](wiki) del proyecto, incluyendo:

- Guía de arquitectura
- Manual de operaciones
- Guías de troubleshooting
- Mejores prácticas
- Procedimientos de backup y restauración

## 💡 Casos de Uso

- Startups que necesitan una infraestructura robusta y segura
- Equipos de desarrollo que requieren CI/CD y monitoreo
- Empresas que buscan implementar DevSecOps
- Proyectos que necesitan cumplir con estándares de seguridad

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor, lee la [guía de contribución](CONTRIBUTING.md) para más detalles.

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 💬 Soporte

- 📧 Email: tu@email.com
- 💬 Discord: [Únete a nuestro servidor](https://discord.gg/tu-servidor)
- 📚 Issues: [GitHub Issues](https://github.com/tu-usuario/infraestructura-devsecops/issues)

## ⭐️ Muestra tu apoyo

Dale una estrella ⭐️ si este proyecto te ayudó!

## 🙏 Agradecimientos

- [Terraform](https://www.terraform.io/)
- [Docker](https://www.docker.com/)
- [Prometheus](https://prometheus.io/)
- [Grafana](https://grafana.com/)
- [Elastic](https://www.elastic.co/)
- [Jenkins](https://www.jenkins.io/)

## 📈 Roadmap

- [ ] Soporte para múltiples regiones de AWS
- [ ] Integración con Kubernetes
- [ ] Dashboards adicionales
- [ ] Soporte para otros proveedores cloud
- [ ] Sistema de documentación automática
