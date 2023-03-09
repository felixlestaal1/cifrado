#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Simplemente para controlar lo que pasa cuando se presiona ctrl + c
trap ctrl_c INT

function ctrl_c(){
  echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Exiting...\n${endColour}"
  tput cnorm;exit 1
}

#Funcion para que se muestren los banners
function show_banner(){
  #Listando todo aquello que esta en la carpeta banners
  banners=(banners/*)

  #Seleccion del banner al azar
  banner=${banners[$RANDOM % ${#banners[@]}]} 

  #Se imprime en consola el banner
  cat $banner
}

# Funcion para mostrar el panel de ayuda,tambien llegamos a instanciar el apartado de las banners y los errores se mandan al carajo si no se tiene un banner como tal 

function show_help {
    show_banner
    echo -e "${yellowColour}Uso:${endColour} $(basename "$0")${greenColour} [-h|--help] [-o|--offset OFFSET] [-p|--password PASSWORD] ${endColour}\n"
    echo -e "${grayColour}  Cifra el archivo deseando utilizando el cifrado CÃ©sar con un desplazamiento seleccionado, y guarda el resultado en el archivo deseado. Luego, cifra el archivo de salida utilizando la contraseÃ±a designada y renombra el archivo resultante${endColour}.\n"
    echo -e "${yellowColour}Argumentos:${endColour}"
    echo -e "${yellowColour}  -h, --help ${endColour} ${grayColour}         Muestra este panel de ayuda y sale.${endColour}"
    echo -e "  ${yellowColour}-o, --offset OFFSET${endColour}  ${grayColour}Especifica el valor del desplazamiento para el cifrado. El valor por defecto es 3.${endColour}"
    echo -e " ${yellowColour} -p, --password ${endColour}"
    echo -e " ${grayColour}                      Especifica la contraseÃ±a para cifrar el archivo de salida. Si no se proporciona, se pedirÃ¡ al usuario.${endColour}"
}

# Configuracion por defecto
offset=3
password=""

# Procesar los argumentos de linea de comandos
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--offset)
            offset=$2
            shift
            shift
            ;;
        -p|--password)
            password=$2
            shift
            shift
            ;;
        *)
            if [ -z "$input_file" ]; then
                input_file="$1"
            elif [ -z "$output_file" ]; then
                output_file="$1"
            else
                echo "Error: Demasiados argumentos."
                exit 1
            fi
            shift
            ;;
    esac
done

# Verificar si se proporcionaron los argumentos obligatorios
if [ -z "$input_file" ] || [ -z "$output_file" ]; then
    echo "Error: Falta especificar los argumentos obligatorios."
    show_help
    exit 1
fi

# Pedir el valor del desplazamiento para el cifrado si no se proporciona por linea de comandos
if [ -z "$offset" ]; then
    read -p "Ingrese el valor del desplazamiento: " offset
fi

# Pedir la contraseña si no se proporciona por linea de comandos
if [ -z "$password" ]; then
    read -sp "Ingrese su contraseÃ±a: " password
    echo
fi

# Cifrar el archivo de salida con la contraseña
attempt=1
while [ "$attempt" -le 2 ]; do
    openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file.enc" -pass "pass:$password"
    if [ $? -eq 0 ]; then
        # La contraseÃ±a es correcta
        break
    fi
    attempt=$((attempt+1))
done

# Leer el contenido cifrado del archivo de salida
output=$(<"$output_file.enc")

# Aplicar el cifrado Cesar al contenido cifrado
output=$(echo "$output" | tr "a-zA-Z" "$(echo {a..z}$(echo {a..z} | tr -d ' ')$(echo {A..Z}$(echo {A..Z} | tr -d ' ')) | tr "${offset}-za-${offset}${offset}-ZA-${offset}" "a-zA-Z") )

# Escribir el contenido cifrado y Cesar en el archivo de salida
echo "$output" > "$output_file"
