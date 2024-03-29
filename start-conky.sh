#!/bin/bash
# vim: ft=sh:ts=4:sw=4:et:ai:cin

conky_bin="$HOME/Applications/conky-x86_64_31359f305cc885bdd81f445a7400cb22.AppImage"
config_file=$(dirname $0)/"conky.conf"
magic_id=$(md5sum "$config_file" | cut -c -12)
toggle_mode="Y"

usage() {
    echo "USAGE: $(basename $0) [-t] [-p]"
}

start_conky() {
    "$conky_bin" --daemonize --quiet --config="$config_file" -- "$magic_id"
    return $?
}

stop_conky() {
    pkill --signal kill --full "conky.*\s-- $magic_id"
    return $?
}

toggle_conky() {
    if stop_conky; then
        true
    else
        start_conky
    fi
}

restart_conky() {
    stop_conky
    sleep 1
    start_conky
}

while getopts "p:tsrh" opt; do
    case $opt in
    t) # toggle mode off
        toggle_mode="N"
        ;;
    p) # path to conky binary
        conky_bin=$(realpath -- "$OPTARG")
        if [ -x "$conky_bin" ]; then
            echo "Conky binary path: ${conky_bin}"
        else
            echo "ERROR: ${conky_bin} is not executable, path to Conky binary needed\n" >&2
            usage
            exit 1
        fi
        ;;
    s) # stop conky
        stop_conky
        ;;
    r) # restart conky
        restart_conky
        ;;
    h) # help
        usage
        exit 1
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done
shift "$((OPTIND - 1))"

if [ $toggle_mode == "N" ]; then
    toggle_conky
else
    restart_conky
fi

exit 0
