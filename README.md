# 🚀 Infraestructura DevSecOps Automatizada

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-blue.svg)](https://www.terraform.io/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📄 Descripción

Este proyecto presenta una infraestructura DevSecOps completamente automatizada utilizando Docker Compose y Terraform. La configuración incluye servicios esenciales para el monitoreo, gestión de logs, escaneo de vulnerabilidades y pipelines de CI/CD, desplegados en un entorno seguro en AWS.

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
git clone https://github.com/dcarus00/portafolio.git
cd portafolio
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

[El contenido detallado de configuración sigue igual...]

## 🤝 Contribución

Las contribuciones son bienvenidas.
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 💬 Soporte

- 📧 Email: dcaruso@idmovil.com.uy
- 💬 Discord: [Únete a nuestro servidor](https://discord.gg/WcJdRugq8V)
