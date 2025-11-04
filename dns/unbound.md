# Unbound 配置说明文档

## 安装 Unbound

sudo apt-get update <br>
sudo apt-get install unbound<br>

## 编辑 Unbound 配置文件

sudo nano /etc/unbound/unbound.conf<br>

### Unbound 配置文件示例


include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"<br>
server:<br>
    interface: 0.0.0.0<br>
    access-control: 0.0.0.0/0 allow<br>
    cache-max-ttl: 86400<br>
    cache-min-ttl: 3600<br>
    msg-cache-size: 256m<br>   //直接缓冲，设置成内存的1/4
    rrset-cache-size: 256m<br>  // 建议为msg-cache-size的2倍
    module-config: "iterator"<br>
    outgoing-range: 8192<br>
    so-rcvbuf: 4m<br>    //宿主机需要sysctl -w net.core.rmem_max=8388608 或者直接写入到/etc/sysctl.conf；net.core.rmem_max=8388608 设置成内存分块为8兆
    
    prefetch: yes<br>
    prefetch-key: yes<br>    //预读取设置
    
    serve-expired: yes<br>
    serve-expired-ttl: 30<br>
    serve-expired-client-timeout: 1800<br> //过期数据处理

# 设置持久化缓存的路径
auto-trust-anchor-file: "/var/lib/unbound/root.key"<br>

forward-zone:<br>
        name: "."<br>
        forward-addr: 192.168.1.10<br>
        forward-addr: 192.168.1.11<br>

## 语法检查

sudo unbound-checkconf<br>

## 设置本地 DNS

先禁用本地 DNS 服务。

sudo systemctl stop systemd-resolved<br>
sudo systemctl disable systemd-resolved<br>

启用 Unbound 服务。

sudo systemctl start unbound <br>
sudo systemctl enable unbound<br>

修改 resolv.conf 文件，将 nameserver 修改为本地。

sudo nano /etc/resolv.conf<br>
nameserver 127.0.0.1<br>

防止 resolv.conf 被覆盖。

sudo chattr +i /etc/resolv.conf<br>

## 配置文档加入

在 Unbound 配置文件中加入以下内容，以使用 4 线程：

server: <br>
    num-threads: 4<br>

查看 Unbound 服务状态：

sudo unbound-control status <br>

## 递归配置

1. 安装 anchor：<br>
   sudo apt install unbound-anchor<br>

2. 建立所需文件夹：<br>
   sudo mkdir -p /var/lib/unbound<br>

3. 修改文件夹权限：<br>
   sudo chown unbound:unbound /var/lib/unbound<br>

4. 下载根服务器地址：<br>
   sudo wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache<br>

5. 修改权限：<br>
   sudo chown unbound:unbound /var/lib/unbound/root.hints<br>

6. DNSSEC 信任锚检测：<br>
   sudo unbound-anchor -a "/var/lib/unbound/root.key"<br>

7. 编辑 Unbound 配置文件：<br>
   sudo nano /etc/unbound/unbound.conf<br>

### 更新的 Unbound 配置文件

include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"<br>

server:<br>
    interface: 0.0.0.0<br>
    access-control: 0.0.0.0/0 allow<br>
    do-udp: yes<br>
    do-tcp: yes<br>
    prefetch: yes<br>
    prefetch-key: yes<br>
    cache-max-ttl: 86400<br>
    cache-min-ttl: 3600<br>
    msg-cache-size: 50m<br>
    rrset-cache-size: 100m<br>
    module-config: "iterator"<br>
    outgoing-range: 8192<br>
    so-rcvbuf: 4m<br>
    prefetch: yes<br>
    prefetch-key: yes<br>

    cache-max-negative-ttl: 0
     # 设置负面响应的最大缓存时间，单位为秒



### 设置持久化缓存的路径
auto-trust-anchor-file: "/var/lib/unbound/root.key"<br>
root-hints: "/var/lib/unbound/root.hints"<br>

### 启用服务时加载缓存数据
use-caps-for-id: yes<br>
module-config: "iterator"<br>



备用配置：
    interface: 0.0.0.0@53
    access-control: 0.0.0.0/0 allow
    do-ip4: yes
    do-ip6: yes
    prefetch: yes
    prefetch-key: yes
    harden-dnssec-stripped: yes
    harden-large-queries: yes
    cache-max-ttl: 86400
    cache-min-ttl: 3600
    msg-cache-size: 100m
    rrset-cache-size: 200m
    num-threads: 6
    outgoing-range: 2048
    num-queries-per-thread: 1024
    jostle-timeout: 200
    infra-cache-min-rtt: 5000
    infra-cache-max-rtt: 50000
    neg-cache-size: 0



