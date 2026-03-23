#!/bin/bash

### Validamos el ingreso de parámetros ###

# Caso en que no se ingresa ningún parámetro #
if [ -z "$1" ]; then #Con -z se verifica si el string está vacío y con -n si no está vacío.
    echo "Debe ingresar el nombre del archivo (y opcionalmente -d como flag)"
    exit
fi

# Caso en que se ingresa el parámetro optativo -d #
if [ "$1" == "-d" ]; then
	parametro_optativo=$1
	
    # Validamos que se ingrese el nombre del archivo después del parámetro optativo -d #
    if [ -z "$2" ]; then
        echo "Debe ingresar el nombre del archivo despues del parámetro -d"
        exit
    fi

    FILENAME=$2

# Caso en que se ingresa el nombre del archivo sin el parámetro optativo -d #
else
	FILENAME=$1
fi

export FILENAME


### Menú ###

echo -e "Seleccione una de las opciones del menú\n"
salir_del_menu="false"

while [ "$salir_del_menu" != "true" ]
do
    echo "----------   MENU   ----------"
	echo "(1) Crear entorno"
	echo "(2) Correr proceso"
	echo "(3) Mostrar el listado de alumnos ordenados por numero de padron"
	echo "(4) Mostrar las 10 notas mas altas del listado de alumnos"
	echo "(5) Mostrar datos del alumno por numero de padron"
	echo "(6) Salir"

    read -r opcion #Con -r se evita que se interpreten caracteres de escape como parte del string ingresado por el usuario.
    
    case $opcion in
    
    ### Opción 1 ###
    1)
        echo "Creando entorno..."
        mkdir -p ~/EPNro1/entrada ~/EPNro1/salida ~/EPNro1/procesado #Con -p se crean los directorios si no existen, y si existen no da error.

        if [ [ -d ~/EPNro1/entrada ] && [ -d ~/EPNro1/salida ] && [ -d ~/EPNro1/procesado ] ]; then
            echo "Entorno creado con éxito!"
        else
            echo "Error al crear el entorno"
        fi
    ;;
    
    ### Opción 2 ###
    2)

    ;;

    ### Opción 3 ###  
    3)
        if [ -f ~/EPNro1/salida/"$FILENAME.txt" ]; then
            echo -e "Listado de alumnos ordenados por número de padrón:\n"
            sort -n -k1 ~/EPNro1/salida/"$FILENAME.txt" #Con -n se ordena numéricamente de menor a mayor, y con -k1 para que arranque desde la primera columna.
        else
            echo -e "El archivo no existe en la carpeta de salida\n"
        fi
    ;;

    ### Opción 4 ###
    4)
        if [ -f ~/EPNro1/salida/"$FILENAME.txt" ]; then
            echo -e "Las 10 notas más altas del listado de alumnos:\n"
            sort -nr -k5 ~/EPNro1/salida/"$FILENAME.txt" | head -n 10 #Con -nr se ordena numéricamente de mayor a menor (r de reverse), y con -k5 para que arranque desde la quinta columna. Con head -n 10 muestro solo las primeras 10 líneas, el -n es para especificar la cantidad de líneas a mostrar.
        else
            echo -e "El archivo no existe en la carpeta de salida\n"
        fi
    ;;

    ### Opción 5 ###
    5)
        if [ -f ~/EPNro1/salida/"$FILENAME.txt" ]; then
            echo "Ingrese el número de padrón del alumno: "
            read -r padron

            busqueda=$(grep "$padron" ~/EPNro1/salida/"$FILENAME.txt")

            if [ -n "$busqueda" ]; then
                echo -e "Datos del alumno con número de padrón $padron:\n"
                echo "$busqueda"
            else
                echo -e "No se encontró ningún alumno con el número de padrón $padron\n"
            fi
        
        else
            echo -e "El archivo no existe en la carpeta de salida\n"
        fi
    ;;

    ### Opción 6 ###
    6)
        salir_del_menu="true"
    ;;

    ### Opción inválida ###
    *)
        echo "Opción inválida"
    ;;

    esac
done
exit
