#!/bin/bash

# Verifica que se haya pasado un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <subred>"
    echo "Ejemplo: $0 192.168.1.0/24"
    exit 1
fi

# Subred a escanear
RANGO="$1"

# Comprobaciones básicas
command -v nmap >/dev/null 2>&1 || { echo "Error: nmap no está instalado."; exit 2; }

# Descubre IPs activas
echo "[+] Escaneando subred: $RANGO"
IPS=$(nmap -n -sn "$RANGO" 2>/dev/null | awk '/Nmap scan report for/ {print $5}')

# Muestra las IPs encontradas
echo "[+] IPs activas encontradas:"
echo "$IPS"

# Si no hay IPs, salir
if [ -z "$IPS" ]; then
    echo "[!] No se encontraron hosts activos."
    exit 1
fi

# Guarda IPs en archivo temporal
TMP_IPS="$(mktemp)"
echo "$IPS" > "$TMP_IPS"

# Archivo de salida grepable
OUT_GREPABLE="AllPorts"

# Ejecuta nmap una sola vez sobre todas las IPs activas
echo "[+] Escaneando puertos abiertos en IPs activas..."
# Ajusta --min-rate o -sS/-sT según privilegios y estabilidad de red
nmap --top-ports 300 --open -sS --min-rate 3000 -n -Pn -vvv -oG "$OUT_GREPABLE" -iL "$TMP_IPS" 2>/dev/null

echo "[+] Archivo grepable generado: $OUT_GREPABLE"

# Limpieza
rm -f "$TMP_IPS"

exit 0
