#!/usr/bin/env bash

PORT=22
ROOT_LOGIN="false"

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
  echo "[+] Installing ssh to the system installed..."
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

activating_ssh() {

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

  echo "
# SSH Configuration Created by Morphus's script
Port $PORT
PasswordAuthentication yes
" > $ssh_config_path
  
  if [ $ROOT_LOGIN == "true" ]
  then
    echo "[+] Root Login Activated"
    
    echo "PermitRootLogin yes" >> $ssh_config_path
  fi

  active_ssh_as_service
  sleep 1
  echo "[+] ssh services running on $PORT"
  sleep 1
  echo "[+] Done!"
  echo "-----------------------------------------------------------------"
}

help() {
  echo "-----------------------------------------------------------------"
  echo "Options:"
  echo "-p or --port    Will set a different port (defaul is 22)"
  echo "-r or --root"   Will permit to root login
  echo "-----------------------------------------------------------------"
  echo "                   Use Cases Examples                            "
  echo "-----------------------------------------------------------------"
  echo "No args: $0"
  echo "With -p arg: $0 -p 222"
  echo "With -r arg: $0 -r"
  echo "With -p and -r args: $0 -r -p 222"  active_ssh_as_service
}

main() {
  install_ssh
  activating_ssh $1
}


if [ $# -eq 0 ]
then
  clear
  help
  main
else
  while getopts 'p:r' flag
  do
    case "${flag}" in
      
      "p") PORT="${OPTARG}";;
      
      "r") ROOT_LOGIN="true";;
    esac
  done
  clear
  help
  main $PORT
fi
