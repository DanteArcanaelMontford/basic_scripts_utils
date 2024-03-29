#!/usr/bin/env bash

root_or_sudo_check() {
  if [ "$(id -u)" != "0" ]
  then
    echo "$red[Warning]$yellow This script must be run as $green root $yellow or $green sudo!$white" 1>&2
    exit 1
  fi
}

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

USER=''
USER_FLAG="false"

ssh_config_path=/etc/ssh/sshd_config.d/morphus.conf

check_stat=`ps -ef | grep 'ssh' | awk '{print $2}'`

init_system=$(ps --no-headers -o comm 1)

################################## FUNCTIONS ##################################

root_or_sudo_check

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
███    ███  ██████  ██████  ██████  ██   ██ ██    ██ ███████ 
████  ████ ██    ██ ██   ██ ██   ██ ██   ██ ██    ██ ██      
██ ████ ██ ██    ██ ██████  ██████  ███████ ██    ██ ███████ 
██  ██  ██ ██    ██ ██   ██ ██      ██   ██ ██    ██      ██ 
██      ██  ██████  ██   ██ ██      ██   ██  ██████  ███████

                          Active SSH
"$white
}
# You can change banner here: https://patorjk.com/software/taag/#p=display&f=ANSI%20Regular&t=Banner



install_ssh() {

  declare -A os_info;
  os_info[/etc/debian_version]="apt-get install -y"
  # os_info[/etc/alpine-release]="apk --update add"
  # os_info[/etc/centos-release]="yum install -y"
  os_info[/etc/redhat-release]="yum install -y"

  create_line
  echo "$red[+]$white Installing ssh to the system..."
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

check_user() {
  declare -A os_info;
  os_info[/etc/debian_version]="sudo"
  os_info[/etc/redhat-release]="wheel"

  for f in ${!os_info[@]}
  do
    if [[ -f $f ]];then
      group=${os_info[$f]}
    fi
  done


  user_exists=$(getent passwd $USER)
  match_sudoer_user=$(sudo -l -U $USER | egrep "Defaults")
  if [[ -z "$user_exists" ]]
  then
    echo "$red[+]$white $red $USER do not exists!$white"
    return
  elif [[ -z "$match_sudoer_user" ]]
  then
    echo "$red[+]$white $red $USER has no sudo powers!$white"
    read -rp "$red[?]$green Want to set this user as sudo?(y/N): " add_to_sudo ; echo -n $white
    
    if [[ "$add_to_sudo" == "y" || "$add_to_sudo" == "Y" ]]
    then
      sleep 1
      echo "$red[+]$green Adding $USER to sudoers group"
      usermod -aG ${group} $USER
      sleep 1
      echo "$red[+]$green Done!$white"
      menu_line
      exit 0
    elif [[ "$add_to_sudo" == "n" || "$add_to_sudo" == "Y" ]]
    then
      echo "$green[+] Try again please! $white"
      run_menu
    else
      echo "$red[Warning] Invalid option, try again please! $white"
      run_menu
    fi
  fi 

  echo "$red[+]$white $green User $USER is sudo $white"
  echo "$red[+]$white $green Done! $white"
  menu_line
  exit 1

}

create_new_user() {
  declare -A os_info;
  os_info[/etc/debian_version]="sudo"
  os_info[/etc/redhat-release]="wheel"

  for f in ${!os_info[@]}
  do
    if [[ -f $f ]];then
      group=${os_info[$f]}
    fi
  done

  echo -n $green
  read -rp "$red[?]$green Please enter the username to be created: " new_user
  if [[ "$new_user" == "" || -z "$new_user" ]]
  then
    echo "$red[!] Invalid input, please try again! $white"
    run_menu
  fi
  adduser $new_user
  menu_line
  sleep 1
  echo "$red[+]$green Adding user to sudoers group"
  usermod -aG ${group} $new_user
  echo "$red[+]$green Done!$white"
  menu_line
  exit 0
  echo -n $white
}

active_ssh_as_service() {
  declare -A os_info;
  os_info[/etc/debian_version]="ssh"
  os_info[/etc/redhat-release]="sshd"

  for f in ${!os_info[@]}
  do
    if [[ -f $f ]];then
      service=${os_info[$f]}
    fi
  done

  echo "$red[+]$white $green Cheking if ssh service is active on the system...$white"
  sleep 1
  if [[ "$init_system" == "systemd" ]]
  then
    sleep 1
    echo "$red[+]$white $green Activating ssh... $white"
    sudo systemctl start ${service} ; sudo systemctl restart ${service}
  elif [[ "$init_system" == "init" ]]
  then
    sleep 1
    echo "$red[+]$white $green Activating ssh...$white"
    echo -n "$red[+]$white "
    sudo echo -n "$green "; service ${service} start ; echo -n "$red[+]$white $green "; sudo service ${service} restart ; echo -n $white
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

usage() {
  create_line
  echo "$cyn|                             $yellow U S A G E                             $cyn|"
  create_line 
  echo "$cyn|$yellow Usage: $0 [option]                                    $cyn|"
  echo "$cyn|$yellow Usage example: $0 -p 2222                             $cyn|"
  echo "$cyn|$yellow options:                                                           $cyn|"
  echo "$cyn|$yellow     -h : Show this help                                            $cyn|"
  echo "$cyn|$yellow     -p : Set a new port to ssh                                     $cyn|"
  create_line
  exit
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
  # help
  main
else
  while getopts "p:h" flag
  do
    case "${flag}" in
      
      "p") PORT="${OPTARG}" ;;
      "h") usage;;

      # "d") DISABLE="true";;

    esac
  done
  clear
  banner
  # help
  main $PORT
fi

####################################################################################
MENU_FLAG=""
menu_line() {
  echo -e "$cyn""--------------------------------------------------------""$white"
}


function show_menu() {
  echo "$red[*]$yellow $(date) $white" 
  menu_line
  echo "$cyn|$green                   Select an Option                   $cyn|$white"
  menu_line
  echo "$cyn|  [1]$white $blue===>$white $yellow To check an existing user to this service $cyn|$white"
  echo "$cyn|  [2]$white $blue===>$white $yellow To create a new user to this service      $cyn|$white"
  menu_line
}

run_menu() {
  while true
  do
    show_menu
    read_input
  done
}

function read_input() {
  local c
  echo -n $yellow
  read -rp "Enter your choice [ 1 or 2 ]:  " c
  menu_line
  echo -n $white
  case $c in
    1) 
      echo -n "$green"
      read -rp "Enter a user to check if sudo powers: " USER
      if [[ "$USER" == "" || -z "$USER" ]]
      then
        echo "$red[!] Invalid input, please try again! $white"
        run_menu
      fi
      menu_line
      echo -n "$white"
      check_user $USER
      run_menu
      exit 0
    ;;
    2) create_new_user ;;
    *) echo "$red[!] Select a valid Option [1 or 2]:  $white" ;;
  esac
}

run_menu

####################################################################################