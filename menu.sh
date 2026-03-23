#!/bin/bash

### Validamos el ingreso de parámetros ###

# Caso en que no se ingresa ningún parámetro #
if [ -z "$1" ]; then #Con -z se verifica si el string está vacío y con -n si no está vacío.
    echo "Debe ingresar el nombre del archivo (y opcionalmente -d como flag)"
    exit
fi

# Caso en que se ingresa el parámetro optativo -d #
if [ "$1" == "-d" ]; then
    echo "Eliminando entorno y cerrando procesos en background..."
    
    pkill -f consolidar.sh #Con pkill mata los procesos que coincidan con el nombre, y con -f se busca en el comando completo, no solo en el nombre del proceso.
    rm -rf ~/EPNro1/ #Con -r (recursivo) se borra el directorio y todo su contenido, y con -f es para que no pida confirmación.
    
    echo "Entorno eliminado y procesos en background cerrados con éxito!"
    
    # Si ademas del parámetro optativo -d se ingresa el nombre del archivo #
    if [ -n "$2" ]; then
        FILENAME=$2
    
    # Si solo ingresó el parámetro optativo -d sin el nombre del archivo #
    else
        echo "No se ingresó ningún nombre de archivo, cerrando el proceso!"
        exit
    fi

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

    echo -e -n "\tOpción: " #Con -n (nonewline) lo que hace es evitar que agregue una nueva línea después del string.
    read -r opcion #Con -r se evita que se interpreten caracteres de escape como parte del string ingresado por el usuario.
    
    case $opcion in
    
    ### Opción 1 ###
    1)
        echo "Creando entorno..."
        mkdir -p ~/EPNro1/entrada ~/EPNro1/salida ~/EPNro1/procesado #Con -p se crean los directorios si no existen, y si existen no da error.

        if [ -d ~/EPNro1/entrada ] && [ -d ~/EPNro1/salida ] && [ -d ~/EPNro1/procesado ]; then
            echo -e "Entorno creado con éxito!\n"
        else
            echo -e "Error al crear el entorno\n"
        fi
    ;;
    
    ### Opción 2 ###
    2)
        # Si existe el archivo consolidar.sh se le da permisos y se ejecuta en background.
        if [ -f ~/EPNro1/consolidar.sh ]; then
            chmod +x ~/EPNro1/consolidar.sh #Con chmod +x se le da permisos de ejecución al archivo consolidar.sh
            echo -e "Ejecutando el proceso...\n"
            ~/EPNro1/consolidar.sh & #Con & se ejecuta el script en segundo plano (background).
        
        else
            # Se crea el archivo consolidar.sh con su código, luego se le da permisos y se ejecuta en background.
            # Se usa << para decirle que todo el bloque de texto que sigue hasta encontrar "fin_del_script_consolidar", sea entrada para el comando cat, y luego esa salida del cat se guarde en el archivo consolidar.sh
            
            cat << 'fin_del_script_consolidar' > ~/EPNro1/consolidar.sh
#!/bin/bash

ejecutar_script="true"
while [ "$ejecutar_script" == "true" ];
do
    for archivo_en_entrada in ~/EPNro1/entrada/*.txt;
    do
        if [ -f "$archivo_en_entrada" ]; then
            echo -e "\nSe agregó un archivo a la carpeta de entrada!"
            echo "Procesando el archivo $archivo_en_entrada"
            cat "$archivo_en_entrada" >> ~/EPNro1/salida/"${FILENAME}.txt"
            mv "$archivo_en_entrada" ~/EPNro1/procesado/
            echo -e "Procesado con éxito!\n"
        fi
    done

    sleep 5 #Con sleep 5 se hace una pausa de 5 segundos.
done
fin_del_script_consolidar
        
            chmod +x ~/EPNro1/consolidar.sh
            echo -e "Ejecutando el proceso...\n"
            ~/EPNro1/consolidar.sh &
        fi
    ;;

    ### Opción 3 ###  
    3)
        if [ -f ~/EPNro1/salida/"${FILENAME}.txt" ]; then
            echo "Listado de alumnos ordenados por número de padrón:"
            sort -n -k1 ~/EPNro1/salida/"${FILENAME}.txt" #Con -n se ordena numéricamente de menor a mayor, y con -k1 para que arranque desde la primera columna.
            echo -e -n "\n"
        else
            echo -e "El archivo ${FILENAME} no existe en la carpeta de salida\n"
        fi
    ;;

    ### Opción 4 ###
    4)
        if [ -f ~/EPNro1/salida/"${FILENAME}.txt" ]; then
            echo "Las 10 notas más altas del listado de alumnos:"
            sort -nr -k5 ~/EPNro1/salida/"${FILENAME}.txt" | head -n 10 #Con -nr se ordena numéricamente de mayor a menor (r de reverse), y con -k5 para que arranque desde la quinta columna. Con head -n 10 muestro solo las primeras 10 líneas, el -n es para especificar la cantidad de líneas a mostrar.
            echo -e -n "\n"
        else
            echo -e "El archivo ${FILENAME} no existe en la carpeta de salida\n"
        fi
    ;;

    ### Opción 5 ###
    5)
        if [ -f ~/EPNro1/salida/"${FILENAME}.txt" ]; then
            echo -n "Ingrese el número de padrón del alumno: "
            read -r padron

            busqueda=$(grep "$padron" ~/EPNro1/salida/"${FILENAME}.txt")

            if [ -n "$busqueda" ]; then
                echo "Datos del alumno con número de padrón $padron:"
                echo -e "$busqueda\n"
            else
                echo -e "No se encontró ningún alumno con el número de padrón $padron\n"
            fi
        
        else
            echo -e "El archivo ${FILENAME} no existe en la carpeta de salida\n"
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
