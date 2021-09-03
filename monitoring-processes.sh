#!/usr/bin/env bash
#----------------------------------------VARIABLES----------------------------------------------------------#
PROCESSES=$(ps -e -o pid --sort -size | head -n 11 | grep [1-9]) # get top10 PROCESSES by RAM usage

#----------------------------------------FUNCTIONS----------------------------------------------------------#
create_line() {
    echo "--------------------------------------------------------------------------------------"
}

check() {
    if [ $? -eq 0 ]; then
        echo "[+] Logs generated successfully"
        return
    fi
    echo "[-] Somethig goes wrong!"
}

create_dir_if_not_exist() {
    if [ ! -d logs ]; then
        mkdir logs
    fi
}

create_log_of_processes() {
    local byte=1024

    for pid in $PROCESSES; do
        local process_name=$(ps -p $pid -o comm=) # get processs name by pid

        local log=$(date +%F,%H:%M:%S,) # get formated date

        local process_size=$(ps -p $pid -o size | grep [1-9]) # get the size of a process in KB

        local size_in_megabytes=$(bc <<<"scale=2;$process_size/$byte") # convert size to megabytes (MB)

        # write log into log files by any process #

        echo -n "$log " >logs/$process_name.log
        echo "$size_in_megabytes MB" >>logs/$process_name.log

    done

}

most_ram_usage_procesess() {
    local byte=1024

    for pid in $PROCESSES; do
        local process_name=$(ps -p $pid -o comm=) # get processs name by pid

        local process_size=$(ps -p $pid -o size | grep [1-9]) # get the size of a process in KB

        local size_in_megabytes=$(bc <<<"scale=2;$process_size/$byte") # convert size to megabytes (MB)

        create_line
        echo "[+] Process name -> $process_name "
        echo "[+] PID -> $pid"
        echo "[+] Size in MB -> $size_in_megabytes MB"
    done
    create_line
}

help() {
    create_line
    echo "[+] -h or --help -> This menu"
    echo "[+] -p or --print -> Print top 10 most usage processes"
    echo "[+] -l or --logs -> Create a directory with basic logs of the most RAM usage processes"
    create_line
}

menu() {
    case $1 in
    "-p" | "--print") most_ram_usage_procesess ;;

    "-l" | "--logs")
        create_dir_if_not_exist
        create_log_of_processes 2>/dev/null
        check
        ;;
    "-h" | "--help") help ;;

    *) help ;;
    esac
}

#----------------------------------------MAIN---------------------------------------------------------------#
clear
menu $1
