
#**************************************************************************************************************************
ASTRA_BASE="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/main-repository/"
ASTRA_EXT="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/extended-repository/"
ASTRA_VERSION_DST="1.8.1"
ASTRA_BUILD_VERSION_DST="1.8.1.16"
ASTRA_VERSION_SRC=`cat /etc/astra_version |head -n| awk -F"." '{print $1}`
ASTRA_BUILD_VERSION_SRC=`cat /etc/astra/build_version | awk -F"." '{print $1}`
#**************************************************************************************************************************

if [ASTRA_VERSION_DST != ASTRA_VERSION_SRC || ASTRA_BUILD_VERSION_DST != ASTRA_BUILD_VERSION_SRC]; then
  #Добавление репозиториев Astra Linux
  cat <<EOL > /etc/apt/sources.list
  deb  1.8_x86-64 contrib main non-free non-free-firmware
  EOL
  
  #Обновление ОС
  apt update -y
  apt install astra-update -y
  astra-update -A -r -T
  
  ASTRA_BUILD_VERSION_SRC_POST=`cat /etc/astra/build_version | awk -F"." '{print $1}`
  
  if [ ASTRA_BUILD_VERSION_DST != ASTRA_BUILD_VERSION_SRC]; then
  echo "Ошибка обновления!\nПроверьте логи обновления на наличие ошибок: /var/log/astra_update*.log"
  exit 1
  fi


else
  echo "ОС уже была обновлена.\nАктуальная версия: $ASTRA_VERSION_SRC\nАктуальный build: $ASTRA_BUILD_VERSION_SRC"
  exit 0
fi
