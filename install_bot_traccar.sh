#!/bin/bash

iptables -F
iptables -X
iptables-save >> /etc/iptables/rules.v4

_install_packges () {

apt -y update &&  apt -y install unzip mysql-server libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libpango1.0-0 libasound2 libcairo2 wget git && apt -y dist-upgrade

}

_install_traccar () {

mysql -u root --execute="ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES; CREATE DATABASE traccar;"
wget https://github.com/traccar/traccar/releases/download/v5.2/traccar-windows-64-5.2.zip
unzip traccar-linux-*.zip && ./traccar.run
cat > /opt/traccar/conf/traccar.xml << EOF
<?xml version='1.0' encoding='UTF-8'?>

<!DOCTYPE properties SYSTEM 'http://java.sun.com/dtd/properties.dtd'>

<properties>

    <entry key="config.default">./conf/default.xml</entry>

    <entry key='database.driver'>com.mysql.cj.jdbc.Driver</entry>
    <entry key='database.url'>jdbc:mysql://localhost/traccar?serverTimezone=UTC&amp;useSSL=false&amp;allowMultiQueries=true&amp;autoReconnect=true&amp;useUnicode=yes&amp;characterEncoding=UTF-8&amp;sessionVariables=sql_mode=''</entry>
    <entry key='database.user'>root</entry>
    <entry key='database.password'>root</entry>

    <entry key='notificator.types'>web,sms</entry>
    <entry key='notificator.sms.manager.class'>org.traccar.sms.HttpSmsClient</entry>
    <entry key='sms.http.url'>http://127.0.0.1:8080/enviar?</entry>
    <entry key='sms.http.template'>
    {"destino": "{phone}","mensagem": "{message}", "token": "Deus-e-Amor"}
    </entry>
    <entry key='status.timeout'>60</entry>

</properties>
EOF
systemctl enable --now mysql
systemctl enable --now traccar

}

_install_vnm () {

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
source ~/.profile
nvm install v12.22.12

}

_clone_bot () {
cd /opt/
git clone https://github.com/Jorge-Nunes/bot-whatsapp.git

}

_install_bot () {

cd /opt/bot-whatsapp && npm install

}

_cp_files_bot () {

cp /opt/bot-whatsapp/Constants.js node_modules/whatsapp-web.js/src/util/
cp /opt/bot-whatsapp/bot-whatsapp.service /etc/systemd/system/

}

_ajuste_systemctl () {

systemctl daemon-reload
systemctl start bot-whatsapp.service

}

_log_bot () {

journalctl -fn 1000

}

_install_packges
sleep 5
_install_traccar
sleep 5
_install_vnm
sleep 5
_clone_bot
sleep 5
_install_bot
sleep 5
_cp_files_bot
sleep 5
_ajuste_systemctl
sleep 5
_log_bot
