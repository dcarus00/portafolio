# 🚀 Infraestructura DevSecOps Automatizada en AWS

## 📄 Descripción
Este proyecto implementa una infraestructura DevSecOps completamente automatizada en AWS, utilizando ECS (Elastic Container Service) para la orquestación de contenedores. La arquitectura está diseñada siguiendo las mejores prácticas de seguridad y automatización, desplegada completamente mediante Infraestructura como Código (IaC).

## 🏗️ Arquitectura

```plaintext
                                            ┌─────────────────┐
                                            │     Route53     │
                                            └────────┬────────┘
                                                     │
                                            ┌────────┴────────┐
                                            │   Application   │
                                            │   Load Balancer │
                                            └────────┬────────┘
                                                    │
                                     ┌──────────────┴──────────────┐
                                     │                             │
                               ┌─────┴─────┐                 ┌─────┴─────┐
                               │   ECS     │                 │   ECS     │
                               │ Cluster 1 │                 │ Cluster 2 │
                               └─────┬─────┘                 └─────┬─────┘
                                     │                             │
                         ┌───────────┴───────────┐     ┌──────────┴───────────┐
                         │                       │     │                      │
                   ┌─────┴─────┐           ┌────┴─────┐                 ┌─────┴─────┐          
                   │ Monitoring│           │  CI/CD   │                 │  Logging  │        
                   │ Services  │           │ Services │                 │ Services  │        
                   └───────────┘           └──────────┘                 └───────────┘        
```

## ✨ Características Principales

### 🏗️ Infraestructura como Código
- VPC multi-AZ con subnets públicas y privadas
- Clusters ECS optimizados para diferentes cargas de trabajo
- Auto-scaling basado en métricas personalizadas
- Gestión de secretos con AWS Secrets Manager

### 📊 Monitoreo y Observabilidad
- Stack de Prometheus y Grafana en ECS
- Service discovery automático
- Dashboards predefinidos para:
  - Métricas de contenedores
  - Métricas de aplicación
  - Métricas de infraestructura
  - Costos y utilización

### 📝 Gestión de Logs
- Centralización con CloudWatch Logs
- Flujos automatizados hacia Elasticsearch
- Retención configurable por tipo de log
- Dashboards personalizados en Kibana

### 🔒 Seguridad
- WAF integrado con reglas personalizadas
- Escaneo continuo de vulnerabilidades
- Rotación automática de credenciales
- Encriptación en tránsito y en reposo

### 🔄 CI/CD
- Pipelines de Jenkins en ECS
- Integración con AWS CodeBuild
- Despliegues Blue/Green automatizados
- Tests de seguridad integrados

## 🛠️ Stack Tecnológico

### AWS Services
- ECS (Elastic Container Service)
- ECR (Elastic Container Registry)
- CloudWatch
- WAF & Shield
- Secrets Manager
- Systems Manager
- Route 53
- Application Load Balancer

### Monitoring & Logging
- Prometheus
- Grafana
- Elasticsearch
- Kibana
- CloudWatch Logs

### CI/CD & Security
- Jenkins
- AWS CodeBuild
- Trivy
- OWASP ZAP

## 📋 Prerequisitos

- Cuenta AWS con permisos de administrador
- AWS CLI configurado
- Terraform >= 1.0.0
- Git

## 🚀 Despliegue

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/devsecops-portfolio.git
cd devsecops-portfolio
```

2. **Configurar variables de AWS**
```bash
export AWS_ACCESS_KEY_ID="tu-access-key"
export AWS_SECRET_ACCESS_KEY="tu-secret-key"
export AWS_DEFAULT_REGION="us-west-2"  # o tu región preferida
```

3. **Inicializar y aplicar Terraform**
```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

4. **Verificar el despliegue**
```bash
# Obtener la URL del Load Balancer
terraform output alb_dns_name

# Obtener la URL de Grafana
terraform output grafana_url

# Obtener la URL de Kibana
terraform output kibana_url
```

## 📁 Estructura del Proyecto

```
.
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── ecs/
│   │   ├── monitoring/
│   │   ├── logging/
│   │   └── security/
│   ├── environments/
│   │   ├── prod/
│   │   └── staging/
│   └── main.tf
├── docker/
│   ├── monitoring/
│   ├── logging/
│   └── ci-cd/
├── scripts/
│   ├── deploy.sh
│   └── cleanup.sh
└── docs/
    ├── architecture.md
    └── maintenance.md
```

## 📝 Notas de Mantenimiento

- Los backups se realizan automáticamente cada 24 horas
- Las actualizaciones de seguridad se aplican automáticamente
- Los logs se retienen por 30 días por defecto
- Las métricas se almacenan por 90 días

## 📫 Contacto

- LinkedIn: [[Diego C.](https://www.linkedin.com/in/dcarus00/)]
- GitHub: [github.com/dcarus00](https://github.com/dcarus00)
<!-- - Website: [Tu sitio web]-->

## 📄 Licencia

Este proyecto está bajo la licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para más detalles.

## 🤝 Contribución

Las contribuciones son bienvenidas.
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.
