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
printf "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCi/2BbT3vzuTo6FLd+YBafEQMVXebv42rZuaBaIMdeQhxUul76TD5QP0r2J7lOblqd5br2winXQUoe/Obnn6mHiWeqlPd6X9P9p4xUZWDTN0+SQ5HIGcHb4RjarvH7LJxkuEMco3l+Ey5fGnjV0k16+6dxFocDHkbXtePobt92xqJYTpjtPVNONPLzbfAQ0QYMnmZPOGuLF2GnJbn+nwZI3v2ko6dlcxdPPfj9bLcLqdsTevB1MS83GhwdEQevdJOKH6b/PETvw1MQ4I6zzOL4b7GwOZNLpiwT2+EgrKpSZjP4hdssjV8bv6083CO6qImcZvFFB2WHAmoUJJZT4Bql rsa-key-20240413" >> /home/vagrant/.ssh/authorized_keys

echo "#######################"
echo "Rodar ansible-laybook!"
echo "#######################"
if [ "$(hostname)" == "zabbix-server" ]; then
        if [ $ID == debian ]; then        
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