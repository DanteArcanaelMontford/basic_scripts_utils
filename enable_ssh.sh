#!/usr/bin/env bash

red=$'\e[1;31m'
green=$'\e[1;32m'
blue=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
orange=$'\33[0;33m'
yellow=$'\33[1;33m'
white=$'\e[0m'

PORT=22
ROOT_LOGIN="false"
DATE=$(date)

ssh_config_path=/etc/ssh/sshd_config.d/morphus.conf

check_stat=`ps -ef | grep 'ssh' | awk '{print $2}'`

init_system=$(ps --no-headers -o comm 1)


create_sshd_config_folder() {
  if [ ! -d /etc/ssh/sshd_config.d ];
  then
    sudo mkdir /etc/ssh/sshd_config.d/
  fi
}


create_line() {
  echo -e "$cyn"----------------------------------------------------------------------"$white"
}

banner() {
  create_line
  echo "$orange
          ██████   █████  ███    ██ ███    ██ ███████ ██████  
          ██   ██ ██   ██ ████   ██ ████   ██ ██      ██   ██ 
          ██████  ███████ ██ ██  ██ ██ ██  ██ █████   ██████  
          ██   ██ ██   ██ ██  ██ ██ ██  ██ ██ ██      ██   ██ 
          ██████  ██   ██ ██   ████ ██   ████ ███████ ██   ██                                                            
"$white
}



install_ssh() {

  declare -A os_info;
  os_info[/etc/debian_version]="apt-get install -y"
  # os_info[/etc/alpine-release]="apk --update add"
  # os_info[/etc/centos-release]="yum install -y"
  os_info[/etc/redhat-release]="yum install -y"

  create_line
  echo "$red[+]$white Installing ssh to the system installed..."
  create_line
  for f in ${!os_info[@]}
  do
    if [[ -f $f ]];then
      package_manager=${os_info[$f]}
    fi
  done
  package="openssh-server"
  echo $orange
  ${package_manager} ${package}
  echo $white
}

active_ssh_as_service() {
  echo "$red[+]$white $green Cheking if ssh service is active on the system...$white"
  sleep 1
  if [[ "$init_system" == "systemd" ]]
  then
    sleep 1
    echo "$red[+]$white $green Activating ssh... $white"
    sudo systemctl start ssh ; sudo systemctl restart ssh
  elif [[ "$init_system" == "init" ]]
  then
    sleep 1
    echo "$red[+]$white $green Activating ssh...$white"
    echo -n "$red[+]$white "
    sudo service ssh start ; sudo service ssh restart
  fi
}

activating_ssh() {

  create_line
  echo "$red[+]$white $green Looking for ssh on the system...$white"
  sleep 1
  echo "$red[+]$white $green ssh founded in the system $white"
  sleep 1
  echo "$red[+]$white $green Detected $init_system $white"

  sleep 1
  echo "$red[+]$white $green Path to ssh config file $ssh_config_path $white"
  sleep 1
  echo "$red[+]$white $green Adding ssh port service on config file...$white"

  echo "
# SSH Configuration Created by Morphus's script
# Date: $DATE
Port $PORT
PasswordAuthentication yes
" > $ssh_config_path
  
  if [ $ROOT_LOGIN == "true" ]
  then
    echo "$red[+]$white $red Root Login Activated $white"
    
    echo "PermitRootLogin yes" >> $ssh_config_path
  fi

  active_ssh_as_service
  sleep 1
  echo "$red[+]$white $green ssh services running on $red $PORT $white"
  sleep 1
  echo "$red[+]$white $green Done! $white"
  create_line
}

help() {
  create_line
  echo $yellow
  echo "Options:"
  echo "-p or --port    Will set a different port (defaul is 22)"
  echo "-r or --root"   Will permit to root login
  create_line
  echo "                   Use Cases Examples                            "
  create_line
  echo $yellow
  echo "No args: $0"
  echo "With -p arg: $0 -p 222"
  echo "With -r arg: $0 -r"
  echo "With -p and -r args: $0 -r -p 222"
  echo $white
}

main() {
  install_ssh
  activating_ssh $1
}


if [ $# -eq 0 ]
then
  # clear
  banner
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
  # clear
  banner
  help
  main $PORT
fi
