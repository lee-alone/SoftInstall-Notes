# vlmcsd - Windows KMS 激活服务

在 Linux (Debian) 上编译部署 vlmcsd，为 Windows 系列系统提供 KMS 激活服务。

## 目录

- [前置说明](#前置说明)
- [依赖安装](#依赖安装)
- [源码获取](#拉取源码)
- [编译](#编译)
- [安装](#安装系统文件)
- [创建服务](#创建-systemd-服务)
- [服务管理](#服务管理)
- [功能说明](#功能说明)

## 前置说明

⚠️ 本教程假设您已使用 **root** 用户或具有 sudo 权限执行操作。

## 依赖安装

更新软件包列表并安装编译所需的依赖：

```bash
apt-get update
apt-get install git gcc make -y
```

## 拉取源码

从 GitHub 克隆 vlmcsd 项目：

```bash
git clone https://github.com/Wind4/vlmcsd.git
```

## 编译

进入项目目录并进行编译：

```bash
cd vlmcsd/
make
```

## 安装系统文件

将编译后的二进制文件复制到系统 bin 目录：

```bash
cp bin/* /usr/local/bin
```

## 创建 systemd 服务

创建 systemd 服务文件以支持自动启动和管理：

```bash
nano /etc/systemd/system/vlmcsd.service
```

粘贴以下内容：

```ini
[Unit]
Description=vlmcsd
Wants=network.target
After=syslog.target

[Service]
Type=forking
PIDFile=/var/run/vlmcsd.pid
ExecStart=/usr/local/bin/vlmcsd -l /var/log/vlmcsd.log -p /var/run/vlmcsd.pid

[Install]
WantedBy=multi-user.target
```

## 服务管理

### 重新加载 systemd

```bash
systemctl daemon-reload
```

### 启动和管理服务

```bash
# 设置开机自启
systemctl enable vlmcsd

# 启动服务
systemctl start vlmcsd

# 停止服务
systemctl stop vlmcsd

# 查看服务状态
systemctl status vlmcsd
```

## 功能说明

### 核心工具

| 工具 | 功能 | 说明 |
|------|------|------|
| `vlmcsd` | 服务器 | KMS 激活服务，监听请求 |
| `vlmcs` | 测试客户端 | 用于测试 KMS 服务是否正常工作 |

### 日志和配置

- **日志文件**：`/var/log/vlmcsd.log`
- **PID 文件**：`/var/run/vlmcsd.pid`
- **监听地址**：默认 0.0.0.0:1688（KMS 标准端口）

## 测试 KMS 服务

### 使用 vlmcs 本地测试

```bash
# 测试本地 KMS 服务是否可用
vlmcs 127.0.0.1
```

### 从 Windows 客户端测试

在 Windows 命令行中测试激活：

```cmd
slmgr /skms 你的Linux服务器IP
slmgr /ato
slmgr /xpr
```

### 查看日志

```bash
tail -f /var/log/vlmcsd.log
```

## 常见问题

### Q: 激活失败，提示连接拒绝
**A:** 检查防火墙是否开放 1688 端口：
```bash
ufw allow 1688/tcp
ufw allow 1688/udp
```

### Q: 服务无法启动
**A:** 检查日志文件：
```bash
tail -f /var/log/vlmcsd.log
systemctl status vlmcsd
```

### Q: 如何自定义激活端口
**A:** 修改服务文件中的 ExecStart 行，添加 `-P port` 参数：
```bash
ExecStart=/usr/local/bin/vlmcsd -l /var/log/vlmcsd.log -P 自定义端口
```