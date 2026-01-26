# PowerDNS Recursor - DNS 递归解析服务

PowerDNS Recursor 的安装和配置指南，支持传统配置文件和 YAML 配置两种方式。

## 目录

- [安装](#安装-pdns-recursor)
- [基础配置](#配置-pdns-recursor)
- [版本 5.0+ 配置](#50-以上系统配置)
- [启动服务](#启动-pdns-recursor-服务)

## 安装 pdns-recursor

更新软件包列表并安装 pdns-recursor：

```bash
apt update
apt install pdns-recursor -y

# 检查服务状态（此时服务可能启动失败，因为端口冲突，在配置后解决）
systemctl status pdns-recursor
```

## 配置 pdns-recursor

### 编辑配置文件

```bash
nano /etc/powerdns/recursor.conf
```

### 基础配置项

在文件中添加或修改以下配置项：

```ini
refresh-on-ttl-perc=10
local-address=0.0.0.0
local-port=53
allow-from=127.0.0.0/8, 192.168.1.0/24
```

**注意：** 如果与 dnsdist 的 53 端口冲突，可改为 `local-port=5353`

## 5.0 以上系统配置

### 编辑 YAML 配置文件

```bash
nano /etc/powerdns/recursor.yml
```

### 完整配置示例

```yaml
dnssec:
  validation: validate

recursor:
  threads: 4

packetcache:
  max_entries: 500000
  negative_ttl: 60

incoming:
  listen:
    - 0.0.0.0
    - "::"
  allow_from:
    - 192.168.1.0/24
    - 127.0.0.0/8
    - "::1/128"

outgoing:
  source_address:
    - 0.0.0.0
```

## 启动 pdns-recursor 服务

重新启动服务以应用新的配置：

```bash
systemctl restart pdns-recursor

# 检查服务状态，确保其已正常运行
systemctl status pdns-recursor
```