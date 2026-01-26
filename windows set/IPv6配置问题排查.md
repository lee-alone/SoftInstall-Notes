# Windows 11 - IPv6 配置问题排查

解决 Windows 11 无法获取 IPv6 地址或路由的常见问题。

## 问题描述

Windows 11 连接 OpenWrt（或支持 IPv6 的路由器）后，无法自动获得 IPv6 地址或虽然有地址但无 IPv6 网络访问。

## 原理说明

IPv6 地址通过**路由器广告（RA, Router Advertisement）**机制自动配置。常见问题包括：

- 📡 RA 配置不完整
- 🔗 接口配置不正确
- 📋 路由表缺少 IPv6 默认路由

## 快速诊断

### 查看网络配置

打开 `cmd` 或 `PowerShell`，执行：

```cmd
ipconfig /all
```

**关键信息**：

```
以太网适配器 以太网:
   ...
   默认网关. . . . . . . . . . . . . : fe80::be24:11ff:fedb:c987%15
   IPv6 地址. . . . . . . . . . . . : 2001:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx(首选)
```

> 💡 **重点**：默认网关后的 `%15` 表示接口索引，这个数字很重要

## 解决方案

### 方法 1：重置路由器广告（推荐）

1. **记录接口编号**

   运行 `ipconfig /all`，找到 IPv6 地址对应的接口索引（如 `%15`）

2. **删除旧路由**

   ```cmd
   netsh interface ipv6 delete route ::/0 interface=15
   ```

   > ⚠️ **替换 15 为实际的接口索引**

3. **启用路由器发现**

   ```cmd
   netsh interface ipv6 set interface 15 routerdiscovery=enabled
   ```

4. **触发 RA 刷新**

   选择以下任一方法：
   - 拔插网线（断开/连接）
   - 断开/重连 Wi-Fi
   - 使用以下命令刷新接口：

   ```cmd
   netsh interface ipv6 set interface 15 routerdiscovery=enabled
   ```

### 方法 2：释放和重新获取 IPv6 地址

```cmd
# 释放当前 IPv6 地址
ipconfig /release6

# 重新获取 IPv6 地址
ipconfig /renew6
```

### 方法 3：完整重置（如上述方法无效）

```cmd
# 禁用接口
netsh interface ipv6 set interface 15 disabled

# 启用接口
netsh interface ipv6 set interface 15 enabled

# 启用路由器发现
netsh interface ipv6 set interface 15 routerdiscovery=enabled
```

然后重新连接网络或拔插网线。

## 验证 IPv6 连通性

### 使用 ping 测试

```cmd
# ping IPv6 环回地址（本地测试）
ping ::1

# ping 本地链路地址（局域网测试）
ping fe80::1

# ping 公网 IPv6 地址（外网测试）
ping 2001:4860:4860::8888
```

### 使用浏览器验证

访问支持 IPv6 的网站：

- [ipv6.google.com](https://ipv6.google.com)
- [test-ipv6.com](https://test-ipv6.com)
- [ipv6.ua](https://ipv6.ua)

**成功标志**：显示 "你的 IPv6 地址" 或 "✓ IPv6 可用"

### 使用 PowerShell 查看路由表

```powershell
# 查看 IPv6 路由表
netsh interface ipv6 show route

# 查看接口配置
netsh interface ipv6 show interface

# 查看 DNS 服务器
ipconfig /all | findstr "DNS"
```

## 常见问题

### Q：执行命令后仍无法获得 IPv6

A：可能原因：
1. **路由器未启用 IPv6**：检查路由器设置
2. **接口索引错误**：运行 `ipconfig /all` 确认正确的接口号
3. **防火墙限制**：尝试临时关闭防火墙测试
4. **驱动问题**：更新网卡驱动

### Q：能获得地址但无法访问

A：
1. 检查 IPv6 路由表：`netsh interface ipv6 show route`
2. 确认默认网关存在：应显示 `::/0` 的路由
3. 尝试方法 2 重新获取地址

### Q：如何完全禁用 IPv6

A：**不推荐**，但如需禁用：

```powershell
# 以管理员身份运行 PowerShell

# 禁用 IPv6
netsh interface ipv6 set state disabled

# 重新启用 IPv6
netsh interface ipv6 set state enabled
```

## 适用环境

- ✅ OpenWrt 路由器
- ✅ 支持 IPv6 RA 的所有路由器
- ✅ Windows 11 / Windows 10 / Windows Server 2022

## 高级诊断

### 启用详细日志

```powershell
# 查看网络驱动日志
Get-WinEvent -LogName "System" -FilterHashtable @{LogName="System";Level=2,3} | Where-Object {$_.Message -like "*IPv6*"} | Select-Object TimeCreated, Message
```

### 使用 Wireshark 抓包

如果上述方法都无效，可以使用 Wireshark 抓包分析：

1. 在 Wireshark 中过滤：`icmpv6.type == 134`（RA 报文）
2. 查看是否收到路由器的 RA
3. 检查 RA 中是否包含 PIO（Prefix Information Option）

---

**最后更新**：2024-12-15