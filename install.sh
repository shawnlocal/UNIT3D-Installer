#!/usr/bin/env bash

# Включваме цветовете за по-добра визуализация
source tools/colors.sh

# 1. Проверка за root права - задължително за инсталация на пакети
if [[ $EUID -ne 0 ]]; then
   echo -e "\n$Red [ГРЕШКА] Този скрипт ТРЯБВА да се изпълни с sudo или като root! $Color_Off"
   exit 1
fi

echo -e "${BCyan}==============================================${Color_Off}"
echo -e "${BWhite}    UNIT3D Community Installer (v9.2.0)      ${Color_Off}"
echo -e "${BCyan}==============================================${Color_Off}"

# Автоматично засичане на операционната система
case $(head -n1 /etc/issue | cut -f 1 -d ' ') in
    Ubuntu)   type="ubuntu" ;;
    *)        type='' ;;
esac

# Fallback механизъм, ако автоматичното засичане се провали (често при OVH/VPS шаблони)
if [ "$type" = '' ]; then
    echo -e "\n$Red Не успяхме да определим автоматично вашата операционна система! $Color_Off"
    echo -e "\n$Purple Това се случва при някои облачни доставчици. Моля, изберете ръчно: $Color_Off\n"

    PS3='Моля, изберете номер за вашата ОС: '
    options=("Ubuntu 24.04" "Ubuntu 22.04" "Ubuntu 20.04" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Ubuntu 24.04")
                echo 'Ubuntu 24.04 LTS \n \l' > /etc/issue
                type='ubuntu'
                break
                ;;
            "Ubuntu 22.04")
                echo 'Ubuntu 22.04 LTS \n \l' > /etc/issue
                type='ubuntu'
                break
                ;;
            "Ubuntu 20.04")
                echo 'Ubuntu 20.04 LTS \n \l' > /etc/issue
                type='ubuntu'
                break
                ;;
            "Quit")
                echo -e "$Yellow Инсталацията е прекратена. $Color_Off"
                exit 0
                ;;
            *)
                echo -e "$Red Невалидна опция $REPLY $Color_Off"
                ;;
        esac
    done
fi

# Проверка дали съществува съответния скрипт (ubuntu.sh) и стартирането му
if [ -e "$type.sh" ]; then
    echo -e "\n$BGreen Проверката премина успешно! Стартиране на $type.sh... $Color_Off"
    bash "./$type.sh"
else
    echo -e "\n$Red [ГРЕШКА] Файлът $type.sh не беше намерен в текущата директория! $Color_Off"
    exit 1
fi
