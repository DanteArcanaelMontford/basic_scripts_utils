#!/usr/bin/env bash

PORT=22

ssh_config_path=/etc/ssh/sshd_config.d/morphus.conf


check_stat=`ps -ef | grep 'ssh' | awk '{print $2}'`

init_system=$(ps --no-headers -o comm 1)


install_ssh() {

  declare -A os_info;
  os_info[/etc/debian_version]="apt-get install -y"
  os_info[/etc/alpine-release]="apk --update add"
  os_info[/etc/centos-release]="yum install -y"
  os_info[/etc/fedora-release]="dnf install -y"

  echo "-----------------------------------------------------------------"
  echo "[+] Installing ssh to the system if is not installed..."
  echo "-----------------------------------------------------------------"
  for f in ${!os_info[@]}
  do
    if [[ -f $f ]];then
      package_manager=${os_info[$f]}
    fi
  done
  package="ssh"
  ${package_manager} ${package}
}

active_ssh_as_service() {
  echo "[+] Cheking if ssh service is active on the system..."
  sleep 1
  if [[ "$init_system" == "systemd" ]]
  then
    echo "[+] ssh is inactive"
    sleep 1
    echo "[+] Activating ssh..."
    sudo systemctl start ssh ; sudo systemctl restart ssh
  elif [[ "$init_system" == "init" ]]
  then
    echo "[+] ssh is inactive"
    sleep 1
    echo "[+] Activating ssh..."
    echo -n "[+] "
    sudo service ssh start ; sudo service ssh restart
  fi
}

set_new_port() {
  if [ "$2" == "" ]
  then
    echo "-----------------------------------------------------------------"
    echo "[+] ssh port will be set as default 22"
    echo "[+] To change the port $0 PORT"
    echo "[+] Exemple: $0 2222"
    sleep 1
  else
    PORT=$1
  fi
}

activating_ssh() {

  set_new_port $1

  echo "-----------------------------------------------------------------"
  echo "[+] Looking for ssh on the system..."
  sleep 1
  echo "[+] ssh founded in the system"
  sleep 1
  echo "[+] Detected $init_system"

  sleep 1
  echo "[+] Path to ssh config file $ssh_config_path"
  sleep 1
  echo "[+] Adding ssh port service on config file..."

  echo "# SSH Configuration Created by Morphus script
  Port $PORT
  PasswordAuthentication yes
  " > $ssh_config_path

  # PermitRootLogin yes

  active_ssh_as_service
  sleep 1
  echo "[+] ssh services running on $PORT"
  sleep 1
  echo "[+] Done!"
  echo "-----------------------------------------------------------------"
}


install_ssh
activating_ssh $1