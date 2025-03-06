#!/bin/bash

# Si se pasa un argumento, lo usamos como TOP; si no, usamos 'tb_contador' por defecto.
TOP="${1:-tb_contador}"

# Si se pasa un segundo argumento, lo usamos como stop-time; si no, usamos '200ns' por defecto.
STOP_TIME="${2:-200ns}"

# Directorios
SRC_DIR="src"                      # Directorio donde están los archivos fuente VHDL
TB_DIR="tb"                        # Directorio donde está el archivo de prueba (testbench)
SIM_DIR="sim/$TOP"                 # Directorio de simulación basado en el nombre del TOP
VHDL_SOURCES=$(find $SRC_DIR $TB_DIR -name "*.vhd")  # Todos los archivos .vhd
ghw_FILE="$SIM_DIR/wave.ghw"       # Archivo ghw generado
GTKWAVE_SCRIPT="$SIM_DIR/signals.gtkw"  # Archivo de configuración para GTKWave
CONF_TCL="conf.tcl"                # Script TCL para GTKWave

echo "Limpiando los objetos .cf"
rm -rf *.cf
# Crear el directorio de simulación si no existe
mkdir -p $SIM_DIR

# Paso 1: Analizar todos los archivos .vhd (fuentes + testbenches)
echo "Analizando archivos VHDL..."
ghdl -a --std=08 -fsynopsys $VHDL_SOURCES

# Paso 2: Compilar el testbench (tb_contador o el valor de TOP)
echo "Compilando el testbench..."
ghdl -e --std=08 -fsynopsys $TOP

# Paso 3: Ejecutar la simulación con GHDL y generar el archivo ghw
echo "Ejecutando simulación hasta $STOP_TIME..."
ghdl -r --std=08 -fsynopsys $TOP --wave=$ghw_FILE --stop-time=$STOP_TIME

# Paso 4: Ejecutar GTKWave con los archivos generados
echo "Abriendo GTKWave..."
gtkwave $ghw_FILE $GTKWAVE_SCRIPT -S $CONF_TCL


echo "Limpiando los objetos .cf"
rm -rf *.cf

echo "Proceso completo!"
