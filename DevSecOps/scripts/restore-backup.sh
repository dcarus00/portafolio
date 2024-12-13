#!/bin/bash

# Directorio de restauración
RESTORE_DIR="/restore"
S3_BUCKET="nombre-del-bucket"

# Crear directorio de restauración si no existe
mkdir -p ${RESTORE_DIR}

echo "Iniciando la restauración desde el bucket S3: ${S3_BUCKET}..."

# Restaurar archivos comprimidos para cada servicio
for service in prometheus elasticsearch grafana; do
    echo "Restaurando ${service}..."
    
    # Descargar el archivo más reciente del bucket S3
    LATEST_BACKUP=$(aws s3 ls "s3://${S3_BUCKET}/${service}/" | sort | tail -n 1 | awk '{print $4}')
    
    if [ -n "${LATEST_BACKUP}" ]; then
        aws s3 cp "s3://${S3_BUCKET}/${service}/${LATEST_BACKUP}" "${RESTORE_DIR}/"
        
        # Descomprimir el archivo en el directorio de restauración
        tar xzf "${RESTORE_DIR}/${LATEST_BACKUP}" -C "${RESTORE_DIR}"
        rm "${RESTORE_DIR}/${LATEST_BACKUP}"
        
        echo "Restauración de ${service} completada."
    else
        echo "No se encontró ningún archivo de backup para ${service}."
    fi
done

echo "Proceso de restauración finalizado."
