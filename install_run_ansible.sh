#!/bin/bash

echo "##############################################"
echo "Verificar se o arquivo /etc/os-release existe!"
echo "##############################################"

if [ -e "/etc/os-release" ]; then
    ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)
else
    echo "O arquivo /etc/os-release não foi encontrado."
fi

echo "#######################################"
echo "Atualizar sistema e instalar o Ansible!"
echo "#######################################"
if [[ $ID == debian ]]; then
   sudo apt-get update -y
   sudo apt-get install -y ansible
else
  sudo yum install epel-release -y
  sudo yum update -y
  sudo yum install ansible -y
fi

echo "##########################################"
echo "add private key for connect SSH with putty"
echo "##########################################"
printf "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8TeteWxq/lkAWSusHgbK2s0ccpw4eifD27IdDhtBFYw62+uBV/rtT3/u5tfo34vadSKLWTrKPsqru4PmqVRayWjGurdhTYYgLFKf8TcG0o7EaplcENghoiZpHcoh8dGRhPvJHpfljP+d/USSUZDVtBD1FM55KEy03vVLy4blAL/vj5K0hOvs2pmiRPkk+rof9O7RyYhC2+9aVaf4Ch29dr/ddfdUjNxuc6kVlfjqPIWWwqcTx5QfQZNYMhAN8YClMvI+/05R2YGdjqbcB/WV3DdRXj9pXPYmFaW4CkGOFmaOiYebcYVr6XSSE8w+acr8WLBmwIY9lxMbanWFjIIo9 ssh-key-2023-09-13" >> /home/vagrant/.ssh/authorized_keys
      
echo "#######################"
echo "Rodar ansible-laybook!"
echo "#######################"

if [ "$(hostname)" == "zabbix-server" ]; then
    # Verifica se o sistema é Debian
    if [ $ID == debian ]; then
        # Se ambas as condições forem verdadeiras, execute seu comando aqui
        echo "########################"
        echo "Instalando zabbix-Server"
        echo "########################"
        ansible-playbook --connection=localhost /ansible/install_zabbix_server/playbook.yaml
    else
        echo "O hostname é zabbix-server, mas o sistema nao e Debian."
    fi
else
        echo "########################"
        echo "Instalando zabbix-agent"
        echo "########################"
        ansible-playbook --connection=localhost /ansible/install_zabbix_agent/playbook.yaml
fi