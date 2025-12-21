## Unbound 递归服务器快速部署教程 (Debian 12)

### ❗ 重要说明
本教程假设您已使用 root 用户登录或通过 su 命令切换到 root 权限执行操作。

### 1. 安装 Unbound

apt update
apt install unbound -y

### 2. Unbound 递归环境准备

确保 DNSSEC 信任锚和根提示文件能正常工作。

# 建立所需文件夹
mkdir -p /var/lib/unbound

# 修改文件夹权限
chown unbound:unbound /var/lib/unbound

# 下载根服务器地址 (root.hints)
wget -O /var/lib/unbound/root.hints [https://www.internic.net/domain/named.cache](https://www.internic.net/domain/named.cache)
chown unbound:unbound /var/lib/unbound/root.hints

# 初始化 DNSSEC 信任锚 (root.key)
unbound-anchor -a "/var/lib/unbound/root.key"

### 3. 编辑 Unbound 配置文件

使用 nano 编辑 Unbound 的主配置文件。

nano /etc/unbound/unbound.conf

# 请将以下内容粘贴到配置文件中：
# -------------------- Unbound 配置开始 (无缩进) --------------------

include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"

server:
interface: 0.0.0.0@53         # 监听所有 IP 的 53 端口
access-control: 127.0.0.0/8 allow
access-control: <你的局域网网段>/<掩码> allow 

num-threads: 4                 # 使用 4 个线程
msg-cache-size: 256m           
rrset-cache-size: 512m         
outgoing-range: 8192           
so-rcvbuf: 8m                  

cache-max-ttl: 86400           # 缓存最大 TTL (24 小时)
cache-min-ttl: 3600            # 缓存最小 TTL
serve-expired: yes             
serve-expired-ttl: 30
serve-expired-client-timeout: 1800

prefetch: yes                  
prefetch-key: yes              
do-udp: yes
do-tcp: yes
module-config: "iterator"      # 纯递归配置
harden-dnssec-stripped: yes    

auto-trust-anchor-file: "/var/lib/unbound/root.key"
root-hints: "/var/lib/unbound/root.hints"
use-caps-for-id: yes 

# -------------------- Unbound 配置结束 --------------------


### 4. 禁用本地 DNS 服务 (systemd-resolved)

# 停止并禁用 systemd-resolved，确保 53 端口可用
systemctl stop systemd-resolved
systemctl disable systemd-resolved

### 5. 启动 Unbound 服务

# 启用 Unbound 服务并设置开机自启
systemctl enable unbound
systemctl start unbound

# 检查配置语法和状态
unbound-checkconf
unbound-control status

### 6. 设置本地 DNS (可选)

# 修改 resolv.conf 文件，将 nameserver 修改为本地回环地址
nano /etc/resolv.conf
# 粘贴内容:
# nameserver 127.0.0.1
#
# 防止 resolv.conf 被覆盖 
# chattr +i /etc/resolv.conf



1.22版所使用配置：

server:
    interface: 0.0.0.0@53
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes

    access-control: 127.0.0.0/8 allow
    access-control: 192.168.1.0/24 allow

    tcp-upstream: yes              # 新增：强制上游查询使用 TCP
    num-threads: 4
    msg-cache-size: 256m
    rrset-cache-size: 512m
    outgoing-range: 8192
    so-rcvbuf: 8m

    cache-max-ttl: 86400
    cache-min-ttl: 3600
    serve-expired: yes
    serve-expired-ttl: 86400
    serve-expired-reply-ttl: 30
    serve-expired-client-timeout: 1800

    prefetch: yes
    prefetch-key: yes

    harden-dnssec-stripped: yes
    harden-glue: yes
    harden-referral-path: yes
    qname-minimisation: yes
    minimal-responses: yes
    use-caps-for-id: yes

    so-reuseport: yes

    private-address: 192.168.0.0/16
    private-address: 10.0.0.0/8
    private-address: 172.16.0.0/12
    private-address: 169.254.0.0/16
    private-address: fd00::/8
    private-address: fe80::/10

    root-hints: "/var/lib/unbound/root.hints"

    module-config: "iterator"  # Pure recursive, no validator module needed for basic DNSSEC

