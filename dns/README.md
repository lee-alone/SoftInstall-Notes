# DNS 配置与部署指南

本目录包含多个 DNS 服务的安装、配置和优化指南。适用于 Linux 系统（主要基于 Debian 12）。

## 📋 目录结构

| 文件 | 描述 | 适用场景 |
|------|------|--------|
| [dnsdist.md](dnsdist.md) | DNS 负载均衡器 | 需要DNS转发、轮询和故障切换 |
| [unbound.md](unbound.md) | 递归 DNS 解析服务器 | 搭建本地 DNS 递归解析，支持 DNSSEC |
| [pdns.md](pdns.md) | PowerDNS Recursor | 高性能递归 DNS 解析，YAML 配置 |
| [dnsmasq.md](dnsmasq.md) | DNS 缓存 & DHCP | OpenWrt/旁路由，域名改写 |

## 🚀 快速开始

### 1. 最小化 DNS 递归解析服务
**推荐：** Unbound + 本地转发

```bash
# 安装 Unbound
apt install unbound -y

# 编辑配置并启动
systemctl start unbound
```

**详见：** [unbound.md](unbound.md)

### 2. 负载均衡与故障转移
**推荐：** dnsdist + Unbound/PowerDNS

```bash
# 安装 dnsdist
apt install dnsdist -y

# 配置上游服务器和转发策略
nano /etc/dnsdist/dnsdist.conf
systemctl start dnsdist
```

**详见：** [dnsdist.md](dnsdist.md)

### 3. OpenWrt/旁路由配置
**推荐：** dnsmasq + 域名改写

```bash
# 关闭轮询功能
mkdir -p /etc/dnsmasq.d
echo "no-round-robin" > /etc/dnsmasq.d/fix-order.conf

# 重启 dnsmasq
/etc/init.d/dnsmasq restart
```

**详见：** [dnsmasq.md](dnsmasq.md)

## 🔧 常见配置场景

### 场景 1：家庭网络 DNS
**组件：** Unbound (递归) + dnsdist (转发)

```
请求 → dnsdist (53) → Unbound (递归查询) → 互联网
              ↓
            缓存
```

### 场景 2：OpenWrt 旁路由
**组件：** dnsmasq (本地) + 上游递归

```
请求 → dnsmasq (53) → [本地改写] → 上游 DNS
                           ↓
                    [缓存 & DHCP]
```

### 场景 3：企业 DNS 服务
**组件：** dnsdist + PowerDNS Recursor

```
请求 → dnsdist (LB) → PowerDNS (递归查询)
                ↓
            故障转移
```

## 📚 各服务特点对比

| 功能 | dnsdist | Unbound | PowerDNS | dnsmasq |
|------|---------|---------|----------|---------|
| 递归解析 | ❌ | ✅ | ✅ | ✅ |
| 负载均衡 | ✅ | ❌ | ❌ | ❌ |
| 故障转移 | ✅ | ❌ | ❌ | ❌ |
| DNSSEC | ✅ | ✅ | ✅ | ✅ |
| 缓存 | ✅ | ✅ | ✅ | ✅ |
| Web 界面 | ✅ | ❌ | ❌ | ✅ (OpenWrt) |
| YAML 配置 | ❌ | ❌ | ✅ | ❌ |

## ⚙️ 端口规划建议

| 服务 | 默认端口 | 备注 |
|------|---------|------|
| dnsdist | 53 (UDP/TCP) | 监听公网，转发到上游 |
| Unbound | 53 (UDP/TCP) | 监听本地，递归查询 |
| PowerDNS | 5343 (默认) | 可自定义，避免冲突 |
| dnsmasq | 53 (UDP/TCP) | OpenWrt 默认 |

## 🔒 安全建议

1. **启用 DNSSEC 验证**
   ```bash
   # Unbound
   harden-dnssec-stripped: yes
   auto-trust-anchor-file: "/var/lib/unbound/root.key"
   ```

2. **限制访问范围**
   ```bash
   # 仅允许本地和局域网
   access-control: 127.0.0.0/8 allow
   access-control: 192.168.0.0/16 allow
   ```

3. **启用防火墙规则**
   ```bash
   # 仅允许指定源的 DNS 查询
   ufw allow from 192.168.1.0/24 to any port 53
   ```

4. **定期更新根密钥**
   ```bash
   unbound-anchor -a "/var/lib/unbound/root.key"
   ```

## 📖 详细文档

- **[dnsdist 完整指南](dnsdist.md)**：负载均衡、故障转移、Web 管理界面
- **[Unbound 完整指南](unbound.md)**：递归解析、DNSSEC、性能优化
- **[PowerDNS 完整指南](pdns.md)**：YAML 配置、高级选项
- **[dnsmasq 完整指南](dnsmasq.md)**：域名改写、轮询控制、防火墙

## 🐛 常见问题

### 问题 1：端口冲突
**症状：** 多个 DNS 服务无法同时启动

**解决：**
```bash
# 查看哪个进程占用了 53 端口
lsof -i :53

# 修改其中一个服务的端口
# 例如：PowerDNS 改为 5353
nano /etc/powerdns/recursor.conf
# 修改 local-port=5353
systemctl restart pdns-recursor
```

### 问题 2：DNS 泄露
**症状：** 本应转发的请求绕过了 dnsdist

**解决：**
```bash
# 确保防火墙启用"丢弃无效数据包"选项
# 不使用旁路由模式，改用主路由模式
```

### 问题 3：缓存未生效
**症状：** DNS 响应速度没有改善

**解决：**
```bash
# 检查缓存大小配置
# Unbound
msg-cache-size: 256m
rrset-cache-size: 512m

# 清空缓存后重启
systemctl restart unbound
```

## 🔄 更新日志

- **2024-12-15**：新增 Unbound 1.22 版本配置
- **2024-12-10**：完成全部文档改写，统一 Markdown 格式
- **2024-12-05**：发布初版本

## 📞 参考资源

- [Unbound 官方文档](https://nlnetlabs.nl/projects/unbound/about/)
- [PowerDNS 官方文档](https://doc.powerdns.com/)
- [dnsdist 官方文档](https://dnsdist.org/)
- [dnsmasq 官方网站](http://www.thekelleys.org.uk/dnsmasq/doc.html)

---

**最后更新：** 2024-12-15  
**维护者：** DNS 配置团队
