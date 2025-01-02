# Unbound 配置说明文档

## 安装 Unbound

sudo apt-get update 
sudo apt-get install unbound

## 编辑 Unbound 配置文件

sudo nano /etc/unbound/unbound.conf

### Unbound 配置文件示例


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

## 语法检查

sudo unbound-checkconf

## 设置本地 DNS

先禁用本地 DNS 服务。

sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

启用 Unbound 服务。

sudo systemctl start unbound 
sudo systemctl enable unbound

修改 resolv.conf 文件，将 nameserver 修改为本地。

sudo nano /etc/resolv.conf
nameserver 127.0.0.1

防止 resolv.conf 被覆盖。

sudo chattr +i /etc/resolv.conf

## 配置文档加入

在 Unbound 配置文件中加入以下内容，以使用 4 线程：

server: 
    num-threads: 4

查看 Unbound 服务状态：

sudo unbound-control status 

## 递归配置

1. 安装 anchor：
   sudo apt install unbound-anchor

2. 建立所需文件夹：
   sudo mkdir -p /var/lib/unbound

3. 修改文件夹权限：
   sudo chown unbound:unbound /var/lib/unbound

4. 下载根服务器地址：
   sudo wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache

5. 修改权限：
   sudo chown unbound:unbound /var/lib/unbound/root.hints

6. DNSSEC 信任锚检测：
   sudo unbound-anchor -a "/var/lib/unbound/root.key"

7. 编辑 Unbound 配置文件：
   sudo nano /etc/unbound/unbound.conf

### 更新的 Unbound 配置文件

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

# 设置持久化缓存的路径
auto-trust-anchor-file: "/var/lib/unbound/root.key"
root-hints: "/var/lib/unbound/root.hints"

# 启用服务时加载缓存数据
use-caps-for-id: yes
module-config: "iterator"
