#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Uso: $0 <archivo_grepeable_nmap>"
    exit 1
fi

archivo="$1"
archivo_salida="FixedPorts.txt"

if [ ! -f "$archivo" ]; then
    echo "Error: El archivo '$archivo' no existe."
    exit 1
fi

# Iniciar el archivo de salida
echo "Análisis de archivo Nmap: $archivo" > "$archivo_salida"
echo "Generado el: $(date)" >> "$archivo_salida"
echo "[*] Extracting information..." >> "$archivo_salida"
echo " " >> "$archivo_salida"
echo "================================================================" >> "$archivo_salida"
echo "" >> "$archivo_salida"

# Procesar cada línea que contiene "Ports:"
while IFS= read -r linea; do
    if [[ "$linea" == *"Ports:"* ]]; then
        # Extraer IP
        ip=$(echo "$linea" | grep -oP 'Host: \K[0-9.]+')
        
        # Extraer puertos
        puertos=$(echo "$linea" | grep -oP 'Ports: \K.*' | \
                  grep -oP '\b(\d+)/open' | cut -d'/' -f1 | sort -nu | tr '\n' ',' | sed 's/,$//')
        
        if [ -n "$puertos" ]; then
            echo "[*] IP Address: $ip" >> "$archivo_salida"
            echo "[*] Open ports: $puertos" >> "$archivo_salida"
            echo "────────────────────────────────────────────────────────────────" >> "$archivo_salida"
            echo "" >> "$archivo_salida"
        fi
    fi
done < "$archivo"

echo "Resultado guardado en: $archivo_salida"
