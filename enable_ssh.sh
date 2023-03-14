#!/usr/bin/env bash

# Verify what Operating System is being used
declare -A os_info;
os_info[/etc/debian_version]="apt-get install -y"
os_info[/etc/alpine-release]="apk --update add"
os_info[/etc/centos-release]="yum install -y"
os_info[/etc/fedora-release]="dnf install -y"

# Get ssh config file if exists
ssh_config_path=$(find /etc/ -name "sshd_config" 2>/dev/null)

check_stat=`ps -ef | grep 'ssh' | awk '{print $2}'`

init_system=$(ps --no-headers -o comm 1)


active_ssh_as_service() {
  ssh_is_inactive_check1=$(sudo systemctl status ssh | grep inactive | awk '{print $2}')
  ssh_is_inactive_check2=$(sudo service ssh status | grep inactive | awk '{print $2}')

  echo "[+] Cheking if ssh service is active on the system..."
  sleep 1
  if [ "$ssh_is_inactive_check1" == "inactive" || "$ssh_is_inactive_check1" == "inactive" ]
  then
    echo "[+] ssh is inactive"
    sleep 1
    echo "[+] Activating ssh..."
    sudo systemctl start ssh
    sleep 1
    echo "[+] ssh $(sudo systemctl status ssh | grep active | awk '{print $2}')"
  else
    echo "[+] ssh is inactive"
    sleep 1
    echo "[+] Activating ssh..."
    sudo service ssh start
    sleep 1
    echo "[+] ssh $(sudo service ssh status | grep active | awk '{print $2}')"
  fi
}

echo "-----------------------------------------------------------------"
if [ -n "$check_stat" ]
then
  echo "[+] Looking for ssh on the system..."
  sleep 1
  echo "[+] ssh founded in the system"
  if [ "$init_system" == "systemd" ]
  then
    sleep 1
    echo "[+] Detected $init_system"
    if [[ -f $ssh_config_path ]]
    then
      sleep 1
      echo "[+] Path to ssh config file $ssh_config_path"
      sleep 1
      echo "[+] Adding ssh port service on config file..."
      # echo "Port 22" >> $ssh_config_path
      ssh_file_port_line=$(grep "Port 22" -rnw /etc/ssh/sshd_config | cut -d ":" -f1)
      sleep 1
      # echo "[+] Port 22 config file added on line $ssh_file_port_line"
      active_ssh_as_service
      sleep 1
      echo "[+] Done!"
      echo "-----------------------------------------------------------------"
    fi
  fi
else
  sleep 1
  echo "[+] Detected $init_system"

  sleep 1
  echo "[+] Path to ssh config file $ssh_config_path"
  sleep 1
  echo "[+] Adding ssh port service on config file..."
  # echo "Port 22" >> $ssh_config_path
  ssh_file_port_line=$(grep "Port 22" -rnw /etc/ssh/sshd_config | cut -d ":" -f1)
  sleep 1
  # echo "[+] Port 22 config file added on line $ssh_file_port_line"
  active_ssh_as_service
  sleep 1
  echo "[+] Done!"
  echo "-----------------------------------------------------------------"

  for f in ${!os_info[@]}
  do
    if [[ -f $f ]];then
      package_manager=${os_info[$f]}
    fi
  done

  package="ssh"

  ${package_manager} ${package}
fi
