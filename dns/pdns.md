apt update
apt install pdns-recursor
systemctl status pdns-recursor
nano /etc/powerdns/recursor.conf
refresh-on-ttl-perc=10
local-address=0.0.0.0
local-port=53
allow-from=127.0.0.0/8, <你的局域网网段>/<掩码> # 限制访问
systemctl restart pdns-recursor
