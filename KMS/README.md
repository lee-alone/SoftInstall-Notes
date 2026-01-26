# KMS - Windows 批量激活服务

vlmcsd 是一个开源的 KMS 激活服务实现，允许在 Linux 服务器上为 Windows 系列系统提供激活服务。

## 📋 内容导航

- [vlmcsd 完整部署指南](vlmcsd.md) - 编译、安装、配置、管理

## 🎯 快速开始

### 最小化部署（5 步）

```bash
# 1. 安装依赖
apt-get update && apt-get install git gcc make -y

# 2. 获取源码
git clone https://github.com/Wind4/vlmcsd.git && cd vlmcsd

# 3. 编译
make

# 4. 安装
cp bin/* /usr/local/bin

# 5. 启动服务
systemctl daemon-reload
systemctl enable vlmcsd
systemctl start vlmcsd
```

## 📖 详细说明

详见 [vlmcsd 完整部署指南](vlmcsd.md)

## 🔍 核心概念

### vlmcsd 的作用

vlmcsd 模拟 Microsoft KMS 服务器，使 Windows 客户端能够通过 KMS 激活（而非产品密钥激活）。

### 适用场景

- ✅ 企业/学校内网环境
- ✅ 自建虚拟化平台
- ✅ 多台 Windows 设备批量激活
- ✅ 无需依赖外部激活服务

### 工作原理

```
Windows 客户端 → 连接 1688 端口 → vlmcsd 服务 → 验证激活请求 → 返回激活成功
```

## 💻 支持的产品

可以激活以下 Windows 产品（使用相应的 GVLK 密钥）：

| 产品 | 操作 | 说明 |
|------|------|------|
| Windows 10 | 通过 slmgr 设置 KMS 服务器 | 大多数版本支持 |
| Windows 11 | 通过 slmgr 设置 KMS 服务器 | 大多数版本支持 |
| Windows Server | 通过 slmgr 设置 KMS 服务器 | 2019、2022 等 |
| Office | 通过 ospp.vbs 设置 KMS 服务器 | 2019、2021 等 |

## 🚀 使用 vlmcsd 激活 Windows

### 在 Windows 上执行

```cmd
# 1. 设置 KMS 服务器地址
slmgr /skms 你的服务器IP

# 2. 执行激活
slmgr /ato

# 3. 检查激活状态
slmgr /xpr
```

### 在 Windows PowerShell（管理员）执行

```powershell
# 设置 KMS 服务器和端口
slmgr /skms 你的服务器IP:1688

# 激活
slmgr /ato

# 查看激活状态和剩余时间
slmgr /dlv
```

## 🔧 常见配置

### 修改监听端口

如果 1688 端口被占用，可以修改 systemd 服务文件：

```bash
nano /etc/systemd/system/vlmcsd.service
```

修改 ExecStart 行，添加 `-P` 参数：

```ini
ExecStart=/usr/local/bin/vlmcsd -l /var/log/vlmcsd.log -p /var/run/vlmcsd.pid -P 2688
```

然后重新加载：

```bash
systemctl daemon-reload
systemctl restart vlmcsd
```

### 允许防火墙通过

```bash
# 如果使用 ufw
ufw allow 1688/tcp
ufw allow 1688/udp

# 如果使用 iptables
iptables -A INPUT -p tcp --dport 1688 -j ACCEPT
iptables -A INPUT -p udp --dport 1688 -j ACCEPT
```

## 🐛 故障排查

### 问题 1：Windows 连接超时

**症状**：`slmgr /ato` 返回连接超时

**解决步骤**：

1. 检查网络连接
```bash
ping 你的Windows客户端IP
```

2. 检查 vlmcsd 是否运行
```bash
systemctl status vlmcsd
netstat -tuln | grep 1688
```

3. 检查防火墙
```bash
ufw status
ufw allow 1688/tcp
```

### 问题 2：服务启动失败

**症状**：`systemctl status vlmcsd` 显示失败

**解决步骤**：

1. 查看详细日志
```bash
journalctl -u vlmcsd -n 50
tail -f /var/log/vlmcsd.log
```

2. 检查端口是否被占用
```bash
netstat -tuln | grep 1688
```

3. 重新编译和安装
```bash
cd vlmcsd/
make clean
make
cp bin/* /usr/local/bin
systemctl restart vlmcsd
```

### 问题 3：激活后提示错误

**症状**：`slmgr /ato` 返回错误代码

**常见错误代码**：

| 错误代码 | 含义 | 解决方案 |
|---------|------|--------|
| 0xC004F038 | 计算机时间差异过大 | 同步时间，参考 [NTP 指南](../NTP/ntp.md) |
| 0x80070426 | 找不到服务 | 检查 KMS 服务器是否运行 |
| 0x80004005 | 连接拒绝 | 检查防火墙和网络 |

## 📊 监控和日志

### 实时查看日志

```bash
tail -f /var/log/vlmcsd.log
```

### 查看激活历史

```bash
grep -i "request" /var/log/vlmcsd.log | tail -20
```

### 监控服务状态

```bash
# 每 10 秒检查一次
watch -n 10 'systemctl status vlmcsd'
```

## 📝 最佳实践

1. **定期更新**
   ```bash
   cd vlmcsd/
   git pull
   make clean && make
   cp bin/* /usr/local/bin
   systemctl restart vlmcsd
   ```

2. **备份配置**
   ```bash
   cp /etc/systemd/system/vlmcsd.service /etc/systemd/system/vlmcsd.service.bak
   ```

3. **使用 DNS 别名**
   - 在内网 DNS 上配置 `kms.example.com` 指向你的服务器
   - 在客户端使用 `slmgr /skms kms.example.com` 以便后期灵活迁移

4. **定期验证**
   ```bash
   vlmcs 127.0.0.1
   ```

## 🔗 相关资源

- [vlmcsd GitHub 仓库](https://github.com/Wind4/vlmcsd)
- [Microsoft KMS 激活](https://learn.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys)
- [Windows 激活故障排除](https://support.microsoft.com/zh-cn/windows)

---

**最后更新**：2024-12-15
