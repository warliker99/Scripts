#!/bin/bash
#**************************************************************************************************************************
ASTRA_BASE="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/main-repository/"
ASTRA_EXT="https://dl.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/2/extended-repository/"
ASTRA_VERSION_DST="1.8.1"
ASTRA_BUILD_VERSION_DST="1.8.1.16"
ASTRA_VERSION_SRC=`cat /etc/astra_version | head -n 1| awk -F"." '{print $1}`
ASTRA_BUILD_VERSION_SRC=`cat /etc/astra/build_version | head -n 1 | awk -F"." '{print $1}`
NOTIFICATION_USER="Добрый день! Ваш компьютер будет обновлен до новой версии ОС Astra Linux через 10 минут.\nПросим вас пожалуйста закрыть критическое ПО для предотвращения проблем с его данными."
NOTIFICATION_USER_POST="Добрый день! На вашем компьютере обновляется операционная система! Просьба не выключать ваш компьютер и не редактировать критические файлы!"
NOTIFICATION_USER_POST_UPGRADE="Добрый день! Ваша ОС успешно обновлена, вы можете продолжить работу. Хорошего вам дня!"
#**************************************************************************************************************************
sudo apt install libdbus-glib-1* fly-notifications -y

cat <<EOL > /etc/xdg/fly-notificationsrc
[Notifications]
ListenForBroadcasts=true
EOL

if [ASTRA_VERSION_DST != ASTRA_VERSION_SRC || ASTRA_BUILD_VERSION_DST != ASTRA_BUILD_VERSION_SRC]; then
  #Добавление репозиториев Astra Linux
  cat <<EOL > /etc/apt/sources.list
  deb $ASTRA_BASE 1.8_x86-64 contrib main non-free non-free-firmware
  EOL
  
  #Обновление репозиториев ОС
  apt update -y
  apt install astra-update -y

  #Оповещение пользователей об обновлении ОС.
  gdbus emit --system --object-path / --signal org.kde.BroadcastNotifications.Notify "{'appIcon': <'network-disconnect'>, 'body': <$NOTIFICATION_USER>, 'summary': <'Обновление ОС.'>, 'timeout': <'600000'>"}
  sleep 600

  gdbus emit --system --object-path / --signal org.kde.BroadcastNotifications.Notify "{'appIcon': <'network-disconnect'>, 'body': <$NOTIFICATION_USER_POST>, 'summary': <'Обновление ОС.'>, 'timeout': <'60000'>"}
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
  gdbus emit --system --object-path / --signal org.kde.BroadcastNotifications.Notify "{'appIcon': <'network-disconnect'>, 'body': <$NOTIFICATION_USER_POST_UPGRADE>, 'summary': <'Обновление ОС.'>, 'timeout': <'60000'>"}
  exit 0
  
fi
