#!/bin/bash

echo "Укажите учетную запись пользователя для подключения по SSH:"
read  LOGIN


echo "Пароль учетной записи пользователя для подключения по SSH:"
read -sr PASSWORD

LIST_HOSTS="sagirova-kg.rec.loc
abramov-ev.rec.loc
aldpro-test-e14.rec.loc
"


for host in $LIST_HOSTS
do
IP_HOST=`ping -c 1 $host | head -n 2| tail -n 1 | awk -F" " '{print $4}'`

if [ -z $IP_HOST ]
then
echo "$host - недоступен"

else
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $LOGIN@$IP_HOST  "hostname && sudo dmidecode -t system | grep Serial"

fi
done
