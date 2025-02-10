
#**************************************************************************************************************************
ASTRA_BASE="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/main-repository/"
ASTRA_EXT="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/extended-repository/"
ASTRA_VERSION_DST="1.8.1"
ASTRA_BUILD_VERSION_DST="1.8.1.16"
ASTRA_VERSION_SRC=`cat /etc/astra_version |head -n| awk -F"." '{print $1}`
ASTRA_BUILD_VERSION_SRC=`cat /etc/astra/build_version | awk -F"." '{print $1}`
#**************************************************************************************************************************


#Добавление репозиториев Astra Linux
cat <<EOL > /etc/apt/sources.list
deb  1.8_x86-64 contrib main non-free non-free-firmware
EOL

#Обновление ОС
apt update -y
apt install astra-update -y
astra-update -A -r -T

