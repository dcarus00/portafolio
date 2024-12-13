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
