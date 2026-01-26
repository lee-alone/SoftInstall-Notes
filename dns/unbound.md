# Unbound - 递归 DNS 解析服务器

基于 Debian 12 的 Unbound 快速部署教程，支持多个版本配置。

## 目录

- [重要说明](#重要说明)
- [安装](#安装-unbound)
- [环境准备](#环境准备)
- [配置文件](#编辑-unbound-配置文件)
- [禁用 systemd-resolved](#禁用-systemd-resolved)
- [启动服务](#启动-unbound-服务)
- [本地 DNS 设置](#设置本地-dns-可选)
- [版本 1.22 配置](#122-版本配置)

## 重要说明

⚠️ 本教程假设您已使用 **root** 用户登录或通过 `su` 命令切换到 root 权限执行操作。

## 安装 Unbound

```bash
apt update
apt install unbound -y
```

## 环境准备

确保 DNSSEC 信任锚和根提示文件能正常工作。

### 创建所需文件夹

```bash
mkdir -p /var/lib/unbound
chown unbound:unbound /var/lib/unbound
```

### 下载根服务器地址

```bash
wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.cache
chown unbound:unbound /var/lib/unbound/root.hints
```

### 初始化 DNSSEC 信任锚

```bash
unbound-anchor -a "/var/lib/unbound/root.key"
```

## 编辑 Unbound 配置文件

```bash
nano /etc/unbound/unbound.conf
```

### 基础配置

```conf
include-toplevel: "/etc/unbound/unbound.conf.d/*.conf"

server:
  interface: 0.0.0.0@53
  access-control: 127.0.0.0/8 allow
  access-control: 192.168.1.0/24 allow
  
  num-threads: 4
  msg-cache-size: 256m
  rrset-cache-size: 512m
  outgoing-range: 8192
  so-rcvbuf: 8m
  
  cache-max-ttl: 86400
  cache-min-ttl: 3600
  serve-expired: yes
  serve-expired-ttl: 30
  serve-expired-client-timeout: 1800
  
  prefetch: yes
  prefetch-key: yes
  do-udp: yes
  do-tcp: yes
  
  module-config: "iterator"
  harden-dnssec-stripped: yes
  
  auto-trust-anchor-file: "/var/lib/unbound/root.key"
  root-hints: "/var/lib/unbound/root.hints"
  use-caps-for-id: yes
```

## 禁用 systemd-resolved

停止并禁用 systemd-resolved，确保 53 端口可用：

```bash
systemctl stop systemd-resolved
systemctl disable systemd-resolved
```

## 启动 Unbound 服务

```bash
# 启用并启动服务
systemctl enable unbound
systemctl start unbound

# 检查配置和状态
unbound-checkconf
unbound-control status
```

## 设置本地 DNS (可选)

编辑 resolv.conf 文件：

```bash
nano /etc/resolv.conf
```

添加内容：

```
nameserver 127.0.0.1
```

### 防止文件被覆盖

```bash
chattr +i /etc/resolv.conf
```

## 1.22 版本配置

### 完整的 Unbound 1.22 配置示例

```conf
server:
  interface: 0.0.0.0@53
  do-ip4: yes
  do-ip6: no
  do-udp: yes
  do-tcp: yes
  
  access-control: 127.0.0.0/8 allow
  access-control: 192.168.1.0/24 allow
  
  tcp-upstream: yes              # 强制上游查询使用 TCP
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
  
  # 私有地址定义
  private-address: 192.168.0.0/16
  private-address: 10.0.0.0/8
  private-address: 172.16.0.0/12
  private-address: 169.254.0.0/16
  private-address: fd00::/8
  private-address: fe80::/10
  
  root-hints: "/var/lib/unbound/root.hints"
  module-config: "iterator"
```