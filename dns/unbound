//普通安装 环境debian
\`\`\`
  sudo apt-get update 
\`\`\`
\`\`\`
sudo apt-get install unbound
\`\`\`
\`\`\`
sudo nano /etc/unbound/unbound.conf
\`\`\`
\`\`\`
include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"
server:
    interface: 0.0.0.0
    access-control: 0.0.0.0/0 allow
    cache-max-ttl: 86400
    cache-min-ttl: 3600
    msg-cache-size: 50m
    rrset-cache-size: 100m
    module-config: "iterator"
    outgoing-range: 8192
    so-rcvbuf: 4m
    prefetch: yes
    prefetch-key: yes

# 设置持久化缓存的路径
auto-trust-anchor-file: "/var/lib/unbound/root.key"

forward-zone:
        name: "."
        forward-addr: 192.168.1.10
        forward-addr: 192.168.1.11
\`\`\`
          
语法检查
\`\`\`
sudo unbound-checkconf
\`\`\`
设置本地dns,禁用systemd-resolved
\`\`\`
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
\`\`\`
先禁用本地dns服务。
\`\`\`
sudo systemctl start unbound 
sudo systemctl enable unbound
\`\`\`
启用unbound服务。
\`\`\`
sudo nano /etc/resolv.conf
nameserver 127.0.0.1
\`\`\`
修改成本地。
\`\`\`
sudo chattr +i /etc/resolv.conf
\`\`\`
防止覆盖



配置文档加入：
server: 
num-threads: 4
使用4线程

sudo unbound-control status 
查看状态



配置递归服务器
Sudo apt install unbound-anchor  //安装anchor
sudo mkdir -p /var/lib/unbound		//建立确定文件夹
sudo chown unbound:unbound /var/lib/unbound	//修改文件夹权限
sudo wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache //下载根服务器地址
sudo chown unbound:unbound /var/lib/unbound/root.hints //修改权限
sudo unbound-anchor -a "/var/lib/unbound/root.key" //dnssec信任锚检测
sudo nano /etc/unbound/unbound.conf //修改配置

\`\`\`
include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"
server:
    interface: 0.0.0.0
    access-control: 0.0.0.0/0 allow
    do-udp: yes
    do-tcp: yes
    prefetch: yes
    prefetch-key: yes

    cache-max-ttl: 86400
    cache-min-ttl: 3600
    msg-cache-size: 50m
    rrset-cache-size: 100m
    module-config: "iterator"
    outgoing-range: 8192
    so-rcvbuf: 4m
    prefetch: yes
    prefetch-key: yes
    num-threads: 4

# 设置持久化缓存的路径
auto-trust-anchor-file: "/var/lib/unbound/root.key"
root-hints: "/var/lib/unbound/root.hints"

# 启用服务时加载缓存数据
use-caps-for-id: yes
module-config: "iterator"
\`\`\`

  
