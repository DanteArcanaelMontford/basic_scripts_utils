#!/usr/bin/env bash

# Verify what Operating System is being used

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

install_ssh

# Get ssh config file if exists
ssh_config_path=$(find /etc/ -name "sshd_config" 2>/dev/null)

check_stat=`ps -ef | grep 'ssh' | awk '{print $2}'`

init_system=$(ps --no-headers -o comm 1)


active_ssh_as_service() {
  echo "[+] Cheking if ssh service is active on the system..."
  sleep 1
  if [[ "$init_system" == "systemd" ]]
  then
    echo "[+] ssh is inactive"
    sleep 1
    echo "[+] Activating ssh..."
    sudo systemctl start ssh
    # sleep 1
    # echo "[+] ssh $(sudo systemctl status ssh | grep active | awk '{print $2}')"
  elif [[ "$init_system" == "init" ]]
  then
    echo "[+] ssh is inactive"
    sleep 1
    echo "[+] Activating ssh..."
    echo -n "[+] "
    sudo service ssh start
    # sleep 1
    # echo "[+] ssh $(sudo service ssh status | grep active | awk '{print $2}')"
  fi
}

echo "-----------------------------------------------------------------"


echo "[+] Looking for ssh on the system..."
sleep 1
echo "[+] ssh founded in the system"
sleep 1
echo "[+] Detected $init_system"

if [[ -f $ssh_config_path ]]
then
  sleep 1
  echo "[+] Path to ssh config file $ssh_config_path"
  sleep 1
  echo "[+] Adding ssh port service on config file..."
  echo "-----------------------------------------------------------------" >> $ssh_config_path
  echo "[!] SSH Configuration Created by Morphus script" >> $ssh_config_path
  echo "-----------------------------------------------------------------" >> $ssh_config_path
  echo "Port 2222" >> $ssh_config_path
  echo "PasswordAuthentication yes" >> $ssh_config_path
  # PermitRootLogin yes
  ssh_file_port_line=$(grep "Port 2222" -rnw /etc/ssh/sshd_config | cut -d ":" -f1)
  sleep 1
  # echo "[+] Port 22 config file added on line $ssh_file_port_line"
  active_ssh_as_service
  sleep 1
  echo "[+] Done!"
  echo "-----------------------------------------------------------------"
fi