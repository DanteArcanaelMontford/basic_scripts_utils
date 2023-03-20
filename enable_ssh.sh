#!/usr/bin/env bash

################################## VARIABLES ##################################
red=$'\e[1;31m'
green=$'\e[1;32m'
blue=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
orange=$'\33[0;33m'
yellow=$'\33[1;33m'
white=$'\e[0m'

PORT=22
DATE=$(date)
DISABLE="false"

ssh_config_path=/etc/ssh/sshd_config.d/morphus.conf

check_stat=`ps -ef | grep 'ssh' | awk '{print $2}'`

init_system=$(ps --no-headers -o comm 1)

################################## FUNCTIONS ##################################

create_sshd_config_folder() {
  if [ ! -d /etc/ssh/sshd_config.d ];
  then
    sudo mkdir /etc/ssh/sshd_config.d/
    sudo chmod +755 /etc/ssh/sshd_config.d/
  fi
}

disable_ssh() {
  if [ -f /etc/ssh/sshd_config.d/morphus.conf ];
  then
    sudo rm -f /etc/ssh/sshd_config.d/morphus.conf
  fi

  if [[ "$init_system" == "systemd" ]]
  then
    sleep 1
    echo "$red[+]$white $green Disabling ssh... $white"
    sudo echo -n "$green "; systemctl stop ssh ; sudo systemctl disable ssh ; echo -n $white
  elif [[ "$init_system" == "init" ]]
  then
    sleep 1
    echo "$red[+]$white $green Activating ssh...$white"
    echo -n "$red[+]$white "
    sudo echo -n "$green "; service ssh stop ; sudo service ssh disable ; echo -n $white
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
    sudo echo -n "$green "; service ssh start ; echo -n "$red[+]$white $green "; sudo service ssh restart ; echo -n $white
  fi
}

activating_ssh() {

  if [ $DISABLE == "true" ]
  then
    create_line
    disable_ssh
    echo "$red[+]$white $green Done! $white"
    create_line
    exit 1
  fi

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
  echo "-p  Will set a different port (defaul is 22)"
  # echo "-d  Disable service and delete config file from path"
  create_line
  echo "                   Use Cases Examples                            "
  create_line
  echo $yellow
  echo "No args: $0"
  echo "With -p arg: $0 -p 222"
  # echo "With -d arg: $0 -d"
  echo $white
}

main() {
  install_ssh
  activating_ssh $1
}

################################## ARGUMENTS AND RUN ##################################
if [ $# -eq 0 ]
then
  clear
  banner
  help
  main
else
  while getopts "d:p" flag
  do
    case "${flag}" in
      
      "p") PORT="${OPTARG}";;
      
      "r") ROOT_LOGIN="true";;

      # "d") DISABLE="true";;

    esac
  done
  clear
  banner
  help
  main $PORT
fi
####################################################################################