#!/usr/bin/env bash

#-----------------------Options----------------
function options {
  echo "-----------------------"
  echo "      Operations       "
  echo "-----------------------"
  echo "[+] (1)-->Add"
  echo "[+] (2)-->Sub"
  echo "[+] (3)-->Mult"
  echo "[+] (4)-->Div"
  echo "[+] (0)-->Exit"
  echo "-----------------------"
}


#----------Operations--------------------------
function calculator {
  while [ true ];
  do
    options
    read -p "Pick an operation >>>  " option
    clear
    
    case  $option in
      1) 
        echo "-----------------------"
        echo "[+]$N1 + $N2 = $[N1 + N2]" ;;
      2) 
        echo "-----------------------"
        echo "[+]$N1 - $N2 = $[N1 - N2]" ;;
      3) 
        echo "-----------------------"
        echo "[+]$N1 * $N2 = $[N1 * N2]" ;;
      4) 
        echo "-----------------------"
        echo "[+]$N1 / $N2 = $[N1 / N2]" ;;
      0) 
          echo "-----------------------"
          echo "[+]Exiting..."
          echo "-----------------------"
          sleep 2s
          break;;
      *) 
        echo "-----------------------"
        echo "[+]Invalid Option" ;;
    esac
  done
}

#---------------Welcome--------------------------

echo "-----------------------"
echo "WELCOME TO CALCULATOR"
echo "-----------------------"
#---------------Input numbers to operate---------
read -p "Enter a number >>>  " N1
read -p "Enter a second number >>> " N2


#----------Loading Calculator-------------------------------
echo "[+]Loading..."
sleep 1s

#------------------Calc func call-----------------------
calculator
