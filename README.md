# Simulated Annealing Heuristic applied to the Travelling Salesman Problem (Julia implementation)

## Uso

Debería funcionar para cualquier instalación de Julia. El archivo principal es main.jl, a éste le pasas como parámetro desde la consola el path al archivo de settings que desees usar. Por ejemplo:

  > julia main.jl settings/settings.txt
  
El archivo main.jl realiza n corridas. Si solo se desea 1 existe el run_once:

  > julia run_once.jl settings/settings-for-single-run.txt
  
Su uso principalmente es replicar una corrida buena. Vienen incluidos dos ejemplos de settings, las mejores corridas de 40 y 150 ciudades respectivamente, se ejecutan: 

  > julia run_once.jl settings/settings-40-best.txt
  
  > julia run_once.jl settings/settings-150-best.txt
  
El primero corre en segundos, el segundo tarda como medio minuto.


Es importante que existan las carpetas results y results/plots. En la primera se guarda en {seed}.txt los resultados de todas las corridas realizadas para la semilla dada en el archivo de settings (cuidado con usar la misma semilla y sobreescribir el archivo de resultados -- igual es buena idea cambiar de semilla maestra con frecuencia). En el segundo se guarda en {subsemilla}.txt los costos de las soluciones aceptadas para la corrida correspondiente a esa subsemilla. 
