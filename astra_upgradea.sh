#!/bin/bash
#**************************************************************************************************************************
ASTRA_BASE="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/main-repository/"
ASTRA_EXT="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/extended-repository/"
ASTRA_VERSION_DST="1.8.1"
ASTRA_BUILD_VERSION_DST="1.8.1.16"
ASTRA_VERSION_SRC=`cat /etc/astra_version | head -n 1| awk -F"." '{print $1}`
ASTRA_BUILD_VERSION_SRC=`cat /etc/astra/build_version | head -n 1 | awk -F"." '{print $1}`
NOTIFICATION_USER="Добрый день! Ваш компьютер будет обновлен до новой версии ОС Astra Linux через 10 минут.\nПросим вас пожалуйста закрыть критическое ПО для предотвращения проблем с его данными."
#**************************************************************************************************************************

if [ASTRA_VERSION_DST != ASTRA_VERSION_SRC || ASTRA_BUILD_VERSION_DST != ASTRA_BUILD_VERSION_SRC]; then
  #Добавление репозиториев Astra Linux
  cat <<EOL > /etc/apt/sources.list
  deb $ASTRA_BASE 1.8_x86-64 contrib main non-free non-free-firmware
  EOL
  
  #Обновление репозиториев ОС
  apt update -y
  apt install astra-update -y

  #Оповещение пользователей об обновлении ОС.
  gdbus emit --system --object-path / --signal org.kde.BroadcastNotifications.Notify "\{'appIcon': <'network-disconnect'>, 'body': <'Тестовое уведомление.'>, 'summary': <'Тестовый заголовок.'>, 'timeout': <'$NOTIFICATION_USER'>}
  sleep 600
  
  #Обновление ОС
  astra-update -A -r -T
  
  ASTRA_BUILD_VERSION_SRC_POST=`cat /etc/astra/build_version | head -n 1 | awk -F"." '{print $1}`
  
  if [ ASTRA_BUILD_VERSION_DST != ASTRA_BUILD_VERSION_SRC]; then
  echo "Ошибка обновления!\nПроверьте логи обновления на наличие ошибок: /var/log/astra_update*.log"
  exit 1
  fi


else

  echo "ОС уже была обновлена.\nАктуальная версия: $ASTRA_VERSION_SRC\nАктуальный build: $ASTRA_BUILD_VERSION_SRC"
  
  #Добавление репозиториев Astra Linux, включая расширенный
  cat <<EOL > /etc/apt/sources.list
  deb $ASTRA_BASE 1.8_x86-64 contrib main non-free non-free-firmware
  deb $ASTRA_EXT 1.8_x86-64 contrib main non-free non-free-firmware
  EOL
  
  #Обновление репозиториев ПО
  apt update -y
  
  exit 0
  
fi
