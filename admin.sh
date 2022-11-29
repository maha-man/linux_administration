# admin script
# Erstellt am 23.09.2021 von Michel
# Letztes Update am 29.10.2022

# Diese Skrippt stellt unfangreiche Tools zur Verfügung die auf einem, mehreren oder allen Servern ausgeführt werden können.

# Das Skript muss auf die jeweilen Bedürfnisse angepasst werden.


##################################################################
#####   Hosnamen und Pakte anpassen                  #############
##################################################################



# Die Server Gruppen


all=(hostname1 hostname2 ...)

group_1=(hostname1 hostname2 ...)

group_3=(hostname1 hostname2 ...)

all_exclude_cl_ic_dmz_db=(hostname1 hostname2 ...)

lxdb=(hostname1 hostname2 ...)

linux_test_server=(hostname1 hostname2 ...)

ceph_cluster_ohne_master=(hostname1 hostname2 ...)

kubernetes_cluster_ohne_master=(hostname1 hostname2 ...)

kubernetes_prod=(hostname1 hostname2 ...)

kubernetes_test=(hostname1 hostname2 ...)

cluster_ohne_master=(thostname1 hostname2 ...)
  
cluster_nur_master=(hostname1 hostname2 ...)


raspberry=(hostname1 hostname2 ...)


group_2=(hostname1 hostname2 ...)


temp=(hostname1 hostname2 ...)



variable_hosts=(hostname1 hostname2 ...)


# Pakete die auf hold gesetzt werden


holdpackete=(mariadb* apache* docker-* *docker cri-tools* kubeadm* kubectl* kubelet* kubernetes-* mongo-tools* mongodb-org* mongodb-clients* mongodb-server* mongodb* mysql-client* mysql-common* mysql-server* containerd* google-chrome* postfix* influxdb* grafana* icinga* gitlab* postgresql* ceph* rabbitmq*)



variable_function ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

shold=$(apt-mark showhold)

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo "variable_function:"

#code

}




#################################################################
##########               Ende Anpassungen              ##########
#################################################################



# Funktionen


log ()

{

pfadlog=$(dirname $0)/log

mkdir -p "$pfadlog"

datum=$(date +%Y_%m_%d__%H_%M_%S)

log="$pfadlog"/"$datum"_$1.log

touch "$log"

}


leerzeilen_aus_log_entfernen ()

{


if [ -f "$1" ]

then

sed -i '/^[[:space:]]*$/d' $1

fi

}


delete_localhost_from_servergroup ()

{

hn=$(hostname)

delete=$hn

serverGruppe=( "${serverGruppe[@]/$delete}" )

}



command_ ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

shold=$(apt-mark showhold)

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo "Kommando:"

echo "$1"

echo "Ergebnis:"

"$1"

}




info ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

apt update 2>&1 >/dev/null

updates=$(apt list --upgradable 2>/dev/null)

shold=$(apt-mark showhold)

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo -----------------------------------------

echo show upgradable

echo "$updates"

echo -----------------------------------------

echo Packete hold: 

echo "$shold"

echo -----------------------------------------


}



update_ ()

{


hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')


echo ----------------------------------------- 

echo "$hn" - "$ipadre" - "$distri" "$restart" 


echo "apt update"

apt update

echo "apt-get dist-upgrade"

apt-get dist-upgrade -y



}



root_email_versand_20.04 ()

{


hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')


echo ----------------------------------------- 

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo "apt update"

apt update


echo 'postfix Installation und Konfiguration'

echo "postfix postfix/mailname string $hn" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt install -y postfix
#apt install -y mailutils

touch /etc/postfix/header_check
printf "/From:.*/ REPLACE From: $hn <linux_root_messages@tltges.local>\n" > /etc/postfix/header_check
 
touch /etc/postfix/canonical
printf 'root         linux_root_messages@tltges.local\n' > /etc/postfix/canonical
postmap /etc/postfix/canonical
 
 
sed -i /relayhost =/d /etc/postfix/main.cf

printf 'smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination\n' >> /etc/postfix/main.cf
 
printf 'canonical_maps = hash:/etc/postfix/canonical\n' >> /etc/postfix/main.cf


printf 'smtp_header_checks = regexp:/etc/postfix/header_check\n' >> /etc/postfix/main.cf

printf 'relayhost = IP Adresse\n' >> /etc/postfix/main.cf

systemctl restart postfix

}




root_email_versand_22.04 ()

{


hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')


echo ----------------------------------------- 

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo "apt update"

apt update


echo 'postfix Installation und Konfiguration'

echo "postfix postfix/mailname string $hn" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install postfix -y

#apt install -y postfix
#apt install -y mailutils

touch /etc/postfix/header_check
printf "/From:.*/ REPLACE From: $hn <linux_root_messages@tltges.local>\n" > /etc/postfix/header_check
 
touch /etc/postfix/canonical
printf 'root         linux_root_messages@tltges.local\n' > /etc/postfix/canonical
postmap /etc/postfix/canonical
 
 
sed -i /relayhost =/d /etc/postfix/main.cf

printf 'smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination\n' >> /etc/postfix/main.cf
 
printf 'canonical_maps = hash:/etc/postfix/canonical\n' >> /etc/postfix/main.cf


printf 'smtp_header_checks = regexp:/etc/postfix/header_check\n' >> /etc/postfix/main.cf

printf 'relayhost = IP Adresse\n' >> /etc/postfix/main.cf

systemctl restart postfix

}




unhold__onlyhold_icinga ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

shold=$(apt-mark showhold)

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo Packete vorher hold: 

echo "$shold"

echo -----------------------------------------

echo "Es wird unhold (only hold icinga*) druchgefuehrt ..."

apt-mark unhold $(apt-mark showhold) 

apt-mark hold icinga2*

echo -----------------------------------------

echo Packete nach hold:

echo -----------------------------------------

apt-mark showhold

}


hOld ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

shold=$(apt-mark showhold)

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo Packete vor hold: 

echo "$shold"

echo -----------------------------------------

echo "Es werden alle Pakte auf hold gesetzt die nicht upgedatet werden duerfen oder die fuer eine Unterbrechung der Applikation sorgen wuerden ..."

echo -----------------------------------------


apt-mark hold $@


 
echo -----------------------------------------

echo Packete nach hold:

echo -----------------------------------------

apt-mark showhold


}


reboot_ ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo ----------------------------------------- 

echo "$hn" - "$ipadre" - "$distri" "$restart" 

echo Reboot wird durchgefuehrt.

reboot

}




git_integration_icinga_plugins ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

apt update 

apt install git -y

chmod a-x /root/.ssh/id_rsa.pub

chmod a-x /root/.ssh/id_rsa

chmod g-r,o-r /root/.ssh/id_rsa

chmod a-x /etc/cron.d/git_server

cd /usr/lib/nagios/plugins


ssh-keyscan -t rsa git.unternehmen.de >> ~/.ssh/known_hosts


git init
# # vorhandener Ordner  wird zum repro hinzugügt
git remote add origin git@git.unternehmen.de:tcit/icinga_plugins.git
git init
git config --global user.email "tcit@unternehmen.de"
git config --global user.name "$hn"
git init
git fetch --all
git reset --hard origin/master
git pull origin master


} 



abfrageListeUpdates () {

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

apt update 2>&1 >/dev/null

updates=$(apt list --upgradable 2>/dev/null | grep -v Auflistung... | grep -v Listing... | wc -l)

if [ ! "$updates" = "0" ]

then
	echo -----------------------------------------
	echo "$hn" - "$ipadre" - "$distri"
	echo "$updates" Updates sind Verfuegbar.	
	echo -----------------------------------------
	

fi

}


abfrageListeSecUpdates () {

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

apt update 2>&1 >/dev/null

secUdades=$(apt list --upgradable 2>/dev/null | grep "\-security" | wc -l)

if [ ! "$secUdades" = "0" ]

then 
	echo -----------------------------------------
	echo "$hn" - "$ipadre" - "$distri"
	echo "$secUdades" Security Updates sind Verfuegbar.	
	echo -----------------------------------------
	

fi

}



abfrageListeNeustart () {

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

day=$(uptime |awk '{print $4}')

up=$(uptime |awk '{print $3}')


if [ ! -z "$restart" ]

then


if  [[ "$day" == *"day"* ]]

then 


if [[ $up -gt 44 ]]

then

echo -----------------------------------------
echo "$hn" - "$ipadre" - "$distri"
echo "$restart"
echo Das System laeuft seit $up Tagen.
echo -----------------------------------------


fi

fi

fi
}



basic_config () {


hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')





echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

chmod a-x /etc/inputrc

chmod a-x /etc/systemd/timesyncd.conf

chmod a-x /etc/ssh/sshd_config.d/login.config

chmod a-x /etc/apt/apt.conf.d/50unattended-upgrades

chmod a-x /root/iptables

	
# disable multipathd 


systemctl disable multipathd

wait

systemctl mask multipathd

wait

systemctl stop multipathd

wait

# automatische upgrades


# Pakete pinnen

apt-mark hold $@



#apt-mark unhold $(apt-mark showhold) 


#  timesyncd konfig


apt purge ntp -y


apt autoremove -y


systemctl daemon-reload

timedatectl set-ntp off

timedatectl set-ntp on

timedatectl set-timezone Europe/Berlin

timedatectl


# apt update und upgrade

echo Paket upgrade

apt update

apt-get dist-upgrade -y


iptables-restore iptables

}



icinga_installation ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

# icinga für 20.04
#wget -O - https://packages.icinga.com/icinga.key | apt-key add -

#echo 'deb https://packages.icinga.com/ubuntu icinga-focal main' > /etc/apt/sources.list.d/icinga-main-focal.list


# icinga für 22.04

apt-get update
apt-get -y install apt-transport-https wget gnupg

wget -O - https://packages.icinga.com/icinga.key | gpg --dearmor -o /usr/share/keyrings/icinga-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-jammy main" > /etc/apt/sources.list.d/jammy-icinga.list
echo "deb-src [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-jammy main" >> /etc/apt/sources.list.d/jammy-icinga.list

apt-get update

apt-get install icinga2-bin -y
apt-get install icinga2-common -y
apt-get install icinga2 -y



apt install monitoring-plugins -y

systemctl |grep icinga

chmod +x /root/*.bash

/root/"$hn"*

sudo sed -i 's/#include <plugins-contrib>/include <plugins-contrib>/' /etc/icinga2/icinga2.conf

service icinga2 restart

rm /root/"$hn"*

}



syslog_server_integration ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo -----------------------------------------

echo "$hn" - "$ipadre" - "$distri" "$restart" 

# Syslog Client restart

chmod a-x /etc/rsyslog.d/99-syslogserver.conf

systemctl restart rsyslog


}

# Funktion reboot cluster ohne master

cluster_ohne_master_reboot_DO_NOT_USE ()

{

min=$1
zwei=2

doubleMin=$((min * zwei))

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

restart=$([ -f /var/run/reboot-required ] && cat /var/run/reboot-required)

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

currentReboot=$(date --date "+$min min")
timeNextReboot=$(date --date "+$doubleMin min")


nodes=("$@")


i=0


for element in ${nodes[@]}


do


((i++))


if [[ $element == $hn ]]

then


echo --------------------------------------------------------------------------

echo Dieser Node: "$hn" - "$ipadre" - "$distri" wird zu folgendem Zeitpunkt neu gestartet: "$currentReboot"


if [[ ! -z "${nodes[i]}" ]]

then

echo Anschließend wird Node "${nodes[i]}" zu folgendem Zeitpunkt neu gestartet: "$timeNextReboot"

echo Bitte darauf achten dass die Partner Nodes in den entsprechenden Culstern voll integriert sind. Falls nicht, dieses Skript mit STRG C abbrechen. Beim Abruch des Skripts werden die geplanten reboots nicht durchgefuehrt.


fi

sleep "$min"m

reboot




fi

done


}




restart-group_2-dev.service ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo 

echo "$hn" - "$ipadre" - "$distri" 


systemctl restart group_2-dev.service

sleep 4

systemctl status group_2-dev.service | grep -m1 userName
systemctl status group_2-dev.service | grep Active


}



restart_group_2-qas.service ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo 

echo "$hn" - "$ipadre" - "$distri" 


systemctl restart group_2-qas.service

sleep 4

systemctl status group_2-qas.service | grep -m1 userName
systemctl status group_2-qas.service | grep Active


}



restart_group_2-prod.service ()

{

hn=$(hostname)

distri=$(cat /etc/*rele* |grep DISTRIB_DESCRIPTION |awk '{print $2}')

ipadre=$(ip a |grep "scope global en" |awk '{print $2}')

echo

echo "$hn" - "$ipadre" - "$distri" 


systemctl restart group_2.service

sleep 4

systemctl status group_2.service | grep -m1 userName
systemctl status group_2.service | grep Active

}


# Funktionn für schalterZugang userName


aktivierenZuganguserName ()

{

echo

datum=$(date +%Y_%m_%d__%H_%M_%S)

hostname

echo $datum

usermod -s /bin/bash group_2

checkAcces=$(grep group_2 /etc/passwd)

if [[ "$checkAcces" == *"nologin"* ]]

then

echo Zugang gesperrt.


elif [[ "$checkAcces" == *"bash"* ]]

then

echo Zugang geoeffnet.

fi

}



deaktivierenZuganguserName ()

{

echo

datum=$(date +%Y_%m_%d__%H_%M_%S)

hostname

echo $datum

usermod -s /sbin/nologin group_2

checkAcces=$(grep group_2 /etc/passwd)

if [[ "$checkAcces" == *"nologin"* ]]

then

echo Zugang gesperrt.


elif [[ "$checkAcces" == *"bash"* ]]

then

echo Zugang geoeffnet.

fi
 

}

######################################################################################
######################################################################################
###########################       Skript          ####################################
######################################################################################
######################################################################################

# Abfrage- und Steurdialog GUI und entsprechende Befehle die ausgefuert und geloggtt werden.


dialog --clear
clear


serverGruppe=$(dialog --menu "Welche Server?" 0 0 0 \
 "linux_test_server" "" "all_exclude_cl_ic_dmz_db" "" "cluster_nur_master" "" "cluster_ohne_master" "" "all" "" "manuelle_Eingabe" "" "raspberry" "" "rueck_kanal_rpx01_snet_ex001" "" "1-gitlab01" "" "group_2" "" "lxdb" "" "1-konf02" "" "variable_hosts" "" "kubernetes_cluster_ohne_master" "" "ceph_cluster_ohne_master" "" "group_3" "" "kubernetes_prod" "" "kubernetes_test" "" "group_1" "" 3>&1 1>&2 2>&3)

 
antwort=$?

if [ $antwort = 1 ]

then

clear

exit

fi


clear


if [[ $serverGruppe == 1-gitlab01 ]]

then 

log 1-gitlab01 

ssh root@1-gitlab01 | tee -a "$log"

exit


elif [[ $serverGruppe == rueck_kanal_rpx01_snet_ex001 ]]

then 

log rueck_kanal_servername1_servername2

ssh -R 8080:us.archive.ubuntu.com:80 root@servername1 -p 239797 | tee -a "$log"

ssh -R 8888:us.archive.ubuntu.com:80 root@servername2 -p 239797 | tee -a "$log"

ssh -R 8888:us.archive.ubuntu.com:80 root@servername3 -p 239797 | tee -a "$log"

exit


elif [[ $serverGruppe == manuelle_Eingabe ]]

then



manuell_=$(dialog --inputbox "Hosts eingeben (mit Leerzeichen trennen):" 0 0 3>&1 1>&2 2>&3)


serverGruppe=($manuell_)




elif [[ $serverGruppe == all_exclude_cl_ic_dmz_db ]]

then

serverGruppe=${all_exclude_cl_ic_dmz_db[@]}

delete_localhost_from_servergroup


elif [[ $serverGruppe == group_1 ]]

then

serverGruppe=${group_1[@]}

delete_localhost_from_servergroup


elif [[ $serverGruppe == lxdb ]]

then

serverGruppe=${lxdb[@]}

delete_localhost_from_servergroup


elif [[ $serverGruppe == group_2 ]]

then

serverGruppe=${group_2[@]}



# Abfrage
dialog --clear
clear


action=$(dialog --menu "userName Zugang aktivieren oder deaktiviern, group_2 Dienste neustarten oder eine andere Aktion?" 0 0 0 \
 "aktivieren" "" "deaktivieren" "" "restart-group_2-dev.service" "" "restart_group_2-qas.service" "" "restart_group_2-prod.service" "" "andere_aktion" "" 3>&1 1>&2 2>&3)


antwort=$?

if [ $antwort = 1 ]

then

clear

exit

fi


clear


####

if [[ $action == andere_aktion ]]

then

clear

:

elif [[ "$action" == *"restart-group_2-dev.service"* ]]

then

ssh root@2-group_2t01 -p 239797 "$(typeset -f restart-group_2-dev.service); restart-group_2-dev.service" | tee -a "$log"

exit

elif [[ "$action" == *"restart_group_2-qas.service"* ]]

then

ssh root@2-group_2t01 -p 239797 "$(typeset -f restart_group_2-qas.service); restart_group_2-qas.service" | tee -a "$log"

exit

elif [[ "$action" == *"restart_group_2-prod.service"* ]]

then


ssh root@1-group_201 -p 239797 "$(typeset -f restart_group_2-prod.service); restart_group_2-prod.service" | tee -a "$log"

exit

else

group_2Hosts=$(dialog --checklist "Für welche Hosts? (Bitte Hosts mit Leertaste auswählen. Merfachauswahl möglich.)" 0 0 4 \
 1-group_201 "" off\
 1-lxdb01 "" off\
 2-group_2t01 "" off\
 2-lxdb01 "" off 3>&1 1>&2 2>&3)


antwort=$?

if [ $antwort = 1 ]

then

clear

exit

fi

clear

log group_2_zugang

if [[ "$group_2Hosts" == *"1-group_201"* ]]

then


if [[ "$action" == "aktivieren" ]]

then

ssh root@1-group_201 -p 239797 "$(typeset -f aktivierenZuganguserName); aktivierenZuganguserName " | tee -a "$log"

fi


if [[ "$action" == "deaktivieren" ]]

then

ssh root@1-group_201 -p 239797 "$(typeset -f deaktivierenZuganguserName); deaktivierenZuganguserName " | tee -a "$log"

fi


fi



if [[ "$group_2Hosts" == *"1-lxdb01"* ]]

then


if [[ "$action" == "aktivieren" ]]

then

ssh root@1-lxdb01 -p 239797 "$(typeset -f aktivierenZuganguserName); aktivierenZuganguserName " | tee -a "$log"

fi


if [[ "$action" == "deaktivieren" ]]

then

ssh root@1-lxdb01 -p 239797 "$(typeset -f deaktivierenZuganguserName); deaktivierenZuganguserName " | tee -a "$log"

fi


fi




if [[ "$group_2Hosts" == *"2-group_2t01"* ]]

then


if [[ "$action" == "aktivieren" ]]

then

ssh root@2-group_2t01 -p 239797 "$(typeset -f aktivierenZuganguserName); aktivierenZuganguserName " | tee -a "$log"

fi


if [[ "$action" == "deaktivieren" ]]

then

ssh root@2-group_2t01 -p 239797 "$(typeset -f deaktivierenZuganguserName); deaktivierenZuganguserName " | tee -a "$log"

fi


fi




if [[ "$group_2Hosts" == *"2-lxdb01"* ]]

then


if [[ "$action" == "aktivieren" ]]

then

ssh root@2-lxdb01 -p 239797 "$(typeset -f aktivierenZuganguserName); aktivierenZuganguserName " | tee -a "$log"

fi


if [[ "$action" == "deaktivieren" ]]

then

ssh root@2-lxdb01 -p 239797 "$(typeset -f deaktivierenZuganguserName); deaktivierenZuganguserName " | tee -a "$log"


fi


fi

exit

fi

######



elif [[ $serverGruppe == raspberry ]]

then

serverGruppe=${raspberry[@]}


elif [[ $serverGruppe == variable_hosts ]]

then

serverGruppe=${variable_hosts[@]}


elif [[ $serverGruppe == linux_test_server ]]

then

serverGruppe=${linux_test_server[@]}


elif [[ $serverGruppe == kubernetes_test ]]

then

serverGruppe=${kubernetes_test[@]}


elif [[ $serverGruppe == kubernetes_prod ]]

then

serverGruppe=${kubernetes_prod[@]}


elif [[ $serverGruppe == all ]]

then

serverGruppe=${all[@]}

delete_localhost_from_servergroup



elif [[ $serverGruppe == group_3 ]]

then

serverGruppe=${group_3[@]}

delete_localhost_from_servergroup




elif [[ $serverGruppe == cluster_nur_master ]]

then

serverGruppe=${cluster_nur_master[@]}


elif [[ $serverGruppe == kubernetes_cluster_ohne_master ]]

then

serverGruppe=${kubernetes_cluster_ohne_master[@]}


elif [[ $serverGruppe == ceph_cluster_ohne_master ]]

then

serverGruppe=${ceph_cluster_ohne_master[@]}


elif [[ $serverGruppe == cluster_ohne_master ]]

then

serverGruppe=${cluster_ohne_master[@]}


# Abfrage
dialog --clear
clear


action=$(dialog --menu "cluster_ohne_master_reboot_DO_NOT_USE?" 0 0 0 \
 "andere_aktion" "" "reboot_DO_NOT_USE" "" 3>&1 1>&2 2>&3)


antwort=$?

if [ $antwort = 1 ]

then

clear

exit

fi

if [[ $action == andere_aktion ]]

then

clear

:

fi

if [[ $action == reboot_DO_NOT_USE ]]

then

abstandReboot=$(dialog --inputbox "In welchem Abstand in Minuten sollen alle Nodes aus Kubernetes und Ceph bei PROD und TEST neu gestartet werden?" 0 0 3>&1 1>&2 2>&3)


antwort=$?

if [ $antwort = 1 ]

then

clear

exit

fi

clear


log cluster_ohne_master_reboot_DO_NOT_USE


for server in ${serverGruppe[@]}

do

ssh root@"$server" -p 239797 "$(typeset -f cluster_ohne_master_reboot_DO_NOT_USE $abstandReboot ${serverGruppe[@]}); cluster_ohne_master_reboot_DO_NOT_USE $abstandReboot ${serverGruppe[@]}" | tee -a "$log"



done

leerzeilen_aus_log_entfernen $log

exit

exit



fi


fi


action=$(dialog --checklist "Welche aktionen sollen für die Server $serverGruppe ausgeführt werden? (Merfachauswahl mit Leertaste möglich.)" 0 0 4 \
 ssh_ "" off\
 command "" off\
 variable_function "" off\
 pentest "" off\
 dateitransfer_zu_remote_servers "" off\
 dateitransfer_von_remote_server "" off\
 unhold__onlyhold_icinga "" off\
 update_ "" off\
 hOld "" off\
 info "" off\
 reboot_ "" off\
 s_key "" off\
 basic_config "" off\
 icinga_installation "" off\
 git_integration_icinga_plugins "" off\
 root_email_versand_20.04 "" off\
 root_email_versand_22.04 "" off\
 syslog_server_integration "" off\
 abfrage_liste "" off 3>&1 1>&2 2>&3)




antwort=$?

if [ $antwort = 1 ]

then

clear

exit

fi

clear



if [[ "$action" == *"s_key"* ]]

then


log s_key


sshSchluessel=$(dialog --inputbox "ssh public key Dateinamen eingeben (Wenn sich der ssh public key nicht im Skriptordner befindet muss auch der Pfad eingetragen werden):" 0 0 3>&1 1>&2 2>&3)

clear

for server in ${serverGruppe[@]}

do

cd $(dirname $0)

ssh-copy-id -f -i "$sshSchluessel" root@"$server" -p 239797 | tee -a "$log"


done




kommando=$(systemctl restart sshd)



for server in ${serverGruppe[@]}

do


echo 

ssh root@"$server" -p 239797 "hostname; echo $kommando; $kommando" | tee -a "$log"

done



fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"syslog_server_integration"* ]]

then

log syslog_server_integration


for server in ${serverGruppe[@]}

do

cd $(dirname $0)

scp -P 239797 99-syslogserver.conf root@"$server":/etc/rsyslog.d/ | tee -a "$log"

done



for server in ${serverGruppe[@]}

do


echo 

ssh root@"$server" -p 239797 "$(typeset -f syslog_server_integration); syslog_server_integration" | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"basic_config"* ]]

then

log basic_config


for server in ${serverGruppe[@]}

do

cd $(dirname $0)

scp -P 239797 inputrc root@"$server":/etc/ | tee -a "$log"

scp -P 239797 timesyncd.conf root@"$server":/etc/systemd/ | tee -a "$log"

scp -P 239797 login.config root@"$server":/etc/ssh/sshd_config.d/ | tee -a "$log"

# Bei ubunute 22.04 sind autmatische updates autmatisch installiert.
#scp -P 239797 50unattended-upgrades root@"$server":/etc/apt/apt.conf.d/ | tee -a "$log"

scp -P 239797 tulpn.sh root@"$server":/root/ | tee -a "$log"

scp -P 239797 kernRej.sh root@"$server":/root/ | tee -a "$log"

scp -P 239797 iptables root@"$server":/root/ | tee -a "$log"


done



for server in ${serverGruppe[@]}

do


echo 

ssh root@"$server" -p 239797 "$(typeset -f basic_config ${holdpackete[@]}); basic_config ${holdpackete[@]}" | tee -a "$log"


done


fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"icinga_installation"* ]]

then

log icinga_installation



for server in ${serverGruppe[@]}

do

cd $(dirname $0)

scp -P 239797 tl* root@"$server":/root/ | tee -a "$log"

done



for server in ${serverGruppe[@]}

do

echo 

ssh root@"$server" -p 239797 "$(typeset -f icinga_installation); icinga_installation" | tee -a "$log"

done


fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"git_integration_icinga_plugins"* ]]

then

log git_integration_icinga_plugins


for server in ${serverGruppe[@]}

do

cd $(dirname $0)

scp -P 239797 git_server root@"$server":/etc/cron.d/ | tee -a "$log"

scp -P 239797 id_rsa.pub root@"$server":/root/.ssh/ | tee -a "$log"


scp -P 239797 id_rsa root@"$server":/root/.ssh/ | tee -a "$log"


done


for server in ${serverGruppe[@]}

do


echo 

ssh root@"$server" -p 239797 "$(typeset -f git_integration_icinga_plugins); git_integration_icinga_plugins" | tee -a "$log"

done


fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"command"* ]]

then

log command

kommando=$(dialog --inputbox "Kommando eingeben (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

for server in ${serverGruppe[@]}

do


echo 

ssh root@"$server" -p 239797 "hostname; echo $kommando; $kommando" | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log




if [[ "$action" == *"pentest"* ]]

then

log command

kommandoFLH=$(dialog --inputbox "Kommandoteil vor host (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

kommandoALH=$(dialog --inputbox "Kommandoteil nach host (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

for server in ${serverGruppe[@]}

do


echo 

$kommandoFLH $server $kommandoALH | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"dateitransfer_zu_remote_servers"* ]]

then

log dateitransfer_zu_remote_servers

source=$(dialog --inputbox "Quellpfad und Datei eingeben (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

desti=$(dialog --inputbox "Zielpfad eingeben (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

echo "Quelldatei:" | tee -a "$log"
echo $source | tee -a "$log"
echo "Zielpfad:" | tee -a "$log"
echo $desti | tee -a "$log"
echo

for server in ${serverGruppe[@]}

do

echo $server | tee -a "$log"

scp -P 239797 "$source" root@$server:$desti | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log

if [[ "$action" == *"dateitransfer_von_remote_server"* ]]

then

log dateitransfer_von_remote_server

source=$(dialog --inputbox "Quellpfad und Datei eingeben (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

desti=$(dialog --inputbox "Zielpfad eingeben (falls noeting mit einfachen Hochkomma):" 0 0 3>&1 1>&2 2>&3)

clear

echo "Quelldatei:" | tee -a "$log"
echo $source | tee -a "$log"
echo "Zielpfad:" | tee -a "$log"
echo $desti | tee -a "$log"
echo


for server in ${serverGruppe[@]}

do

echo $server | tee -a "$log"

scp -P 239797 root@"$server":$source $desti | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"unhold__onlyhold_icinga"* ]]

then

log unhold__onlyhold_icinga


for server in ${serverGruppe[@]}

do 

ssh root@"$server" -p 239797 "$(typeset -f unhold__onlyhold_icinga); unhold__onlyhold_icinga" | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"root_email_versand_20.04"* ]]

then

log root_email_versand_20.04


for server in ${serverGruppe[@]}

do 

ssh root@"$server" -p 239797 "$(typeset -f root_email_versand_20.04); root_email_versand_20.04" | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"root_email_versand_22.04"* ]]

then

log root_email_versand_22.04


for server in ${serverGruppe[@]}

do 

ssh root@"$server" -p 239797 "$(typeset -f root_email_versand_22.04); root_email_versand_22.04" | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"update_"* ]]

then

log update

for server in ${serverGruppe[@]}

do 

ssh root@"$server" -p 239797 "$(typeset -f update_); update_ " | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"hOld"* ]]

then

log hold

for server in ${serverGruppe[@]}



do 

ssh root@"$server" -p 239797 "$(typeset -f hOld ${holdpackete[@]}); hOld ${holdpackete[@]}" | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == "reboot_" ]]

then

log reboot

for server in ${serverGruppe[@]}

do 

ssh root@"$server" -p 239797 "$(typeset -f reboot_); reboot_ " | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log


if [[ "$action" == "variable_function" ]]

then

log variable_function

for server in ${serverGruppe[@]}

do 

ssh root@"$server" -p 239797 "$(typeset -f variable_function); variable_function " | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log


if [[ "$action" == "info" ]]

then

log info

for server in ${serverGruppe[@]}

do 

echo $server

ssh root@"$server" -p 239797 "$(typeset -f info); info " | tee -a "$log"

done

fi

leerzeilen_aus_log_entfernen $log



if [[ "$action" == "abfrage_liste" ]]

then

log abfrage_liste


#DMZ und nicht Ubuntu server werden aus array entfernt.

delete=1-konf02

serverGruppe=( "${serverGruppe[@]/$delete}" )

# delete=tl02-svrsensor01

# serverGruppe=( "${serverGruppe[@]/$delete}" )

# delete=tl01-svrsensor01

# serverGruppe=( "${serverGruppe[@]/$delete}" )

# delete=tl02-senrasp01

# serverGruppe=( "${serverGruppe[@]/$delete}" )


delete=1-snet01

serverGruppe=( "${serverGruppe[@]/$delete}" )


delete=1-rpx01

serverGruppe=( "${serverGruppe[@]/$delete}" )


delete=

serverGruppe=( "${serverGruppe[@]/$delete}" )

upda=0
secUpda=0
resta=0

echo ____________________________________________________________________________________________________ | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"
echo Server die einen Neustart benötigen und seit mehr als 44 tagen laufen: | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"
servercount=0


for server in ${serverGruppe[@]}

do
	((servercount ++))
	
ssh root@"$server" -p 239797 "$(typeset -f abfrageListeNeustart); abfrageListeNeustart" | grep -v WARNING | tee -a "$log"	

done





echo ____________________________________________________________________________________________________ | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"
echo Server für die Updatates Verfügbar sind: | tee -a "$log" 
echo ____________________________________________________________________________________________________ | tee -a "$log"
servercount=0


for server in ${serverGruppe[@]}

do


((servercount ++))


ssh root@"$server" -p 239797 "$(typeset -f abfrageListeUpdates); abfrageListeUpdates" | grep -v WARNING | tee -a "$log"


done




echo ____________________________________________________________________________________________________ | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log" 
echo Server für die Security Updatates Verfügbar sind: | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"


servercount=0

for server in ${serverGruppe[@]}

do

((servercount ++))


ssh root@"$server" -p 239797 "$(typeset -f abfrageListeSecUpdates); abfrageListeSecUpdates" | grep -v WARNING | tee -a "$log"


done



echo ____________________________________________________________________________________________________ | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"
echo Diese "$servercount" Server wurden geprueft: | tee -a "$log"
echo "$serverGruppe" | tee -a "$log"
echo ____________________________________________________________________________________________________ | tee -a "$log"
fi


leerzeilen_aus_log_entfernen $log



if [[ "$action" == *"ssh_"* ]]

then


log ssh


for server in ${serverGruppe[@]}

do

echo $server | tee -a "$log"


ssh root@"$server" -p 239797 | tee -a "$log" 



done

fi

leerzeilen_aus_log_entfernen $log
