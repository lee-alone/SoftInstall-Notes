# dnsmasq - DNS 缓存与 DHCP 服务器

dnsmasq 的实用配置和优化技巧，包括轮询禁用、域名改写和防火墙设置。

## 目录

- [关闭轮询功能](#一关闭高版本的轮询功能)
- [域名改写方案](#二域名改写的方案)
- [防火墙配置](#三关于防火墙)

## 一、关闭高版本的轮询功能

### 背景

dnsmasq 2.88+ 版本默认开启了 `round-robin` 轮询功能，即 IP 池内的 IP 访问一次就向后移动一位，实现轮询。

### 关闭轮询步骤

**步骤 1:** 创建配置文件夹并添加禁用轮询的配置

```bash
mkdir -p /etc/dnsmasq.d
echo "no-round-robin" > /etc/dnsmasq.d/fix-order.conf
```

**步骤 2:** 修改主配置文件

```bash
nano /etc/config/dhcp
```

在 dnsmasq 的配置选项中添加：

```
list confdir '/etc/dnsmasq.d/'
```

**步骤 3:** 重启 dnsmasq

```bash
/etc/init.d/dnsmasq restart
```

## 二、域名改写的方案

### 使用 UCI 命令改写域名

将指定域名的解析结果改写为特定 IP（支持多个 IP 和 IPv6）：

```bash
# IPv6 空值改写
uci add_list dhcp.@dnsmasq[0].address='/example.com/::'

# IPv4 改写
uci add_list dhcp.@dnsmasq[0].address='/example.com/1.1.1.1'
uci add_list dhcp.@dnsmasq[0].address='/example.com/2.2.2.2'
uci add_list dhcp.@dnsmasq[0].address='/example.com/3.3.3.3'

# 提交配置并重启
uci commit dhcp
/etc/init.d/dnsmasq restart
```

### 通过 Web 界面配置

也可以直接在 OpenWrt 管理页面中配置：

1. 进入 **常规** → **地址** 选项
2. 添加条目：
   ```
   /example.com/1.1.1.1
   /example.com/::
   ```
3. 保存配置

## 三、关于防火墙

### 重要建议

- ❌ **不建议使用旁路由模式**
- ✅ **务必在主路由模式下启用"丢弃无效数据包"**

### 作用

启用"丢弃无效数据包"可以：
- 有效减少请求 fallback 到不同 DNS 服务器的情况
- 减少 DNS 泄露风险
- 提高网络稳定性