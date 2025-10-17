# Verifica que se pase el archivo de resultados como argumento
RESULTS_FILE="$1"
if [ -z "$RESULTS_FILE" ]; then
  echo "Error: Debe proporcionar el archivo de resultados (e.g., results/results.jtl)"
  exit 1
fi

# Umbrales definidos
THRESHOLD_P95=500  # Tiempo P95 en milisegundos
THRESHOLD_ERROR_RATE=1.0  # Tasa de error en porcentaje

# Calcular P95 de los tiempos de respuesta (columna 2: elapsed)
P95_TIME=$(awk -F',' 'NR>1 {times[NR-1]=$2} END {asort(times); idx = int((NR-1)*0.95); print times[idx]}' "$RESULTS_FILE")

# Calcular tasa de error (columna 8: success = "true" o "false")
ERROR_RATE=$(awk -F',' 'NR>1 {total++; if($8 != "true") errors++} END {if (total > 0) print (errors/total)*100; else print 0}' "$RESULTS_FILE")

# Mostrar resultados
echo "P95 Response Time: $P95_TIME ms"
echo "Error Rate: $ERROR_RATE%"

# Verificar umbrales
if [ -z "$P95_TIME" ] || [ "$P95_TIME" -gt "$THRESHOLD_P95" ]; then
  echo "FAIL: P95 ($P95_TIME ms) > $THRESHOLD_P95 ms"
  exit 1
fi

if (( $(echo "$ERROR_RATE > $THRESHOLD_ERROR_RATE" | bc -l) )); then
  echo "FAIL: Error Rate ($ERROR_RATE%) > $THRESHOLD_ERROR_RATE%"
  exit 1
fi

echo "PASS: All thresholds met"
exit 0