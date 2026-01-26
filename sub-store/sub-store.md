# Sub-Store 订阅管理服务部署

在自建服务器上部署 Sub-Store 订阅转换和管理服务。

## 目录

- [项目简介](#项目简介)
- [前置准备](#前置准备)
- [部署步骤](#部署步骤)
- [服务管理](#服务管理)
- [配置说明](#配置说明)
- [常见问题](#常见问题)

## 项目简介

Sub-Store 是一个开源的订阅管理和转换工具，支持：

- 📦 **订阅管理**：聚合多个订阅源
- 🔄 **格式转换**：支持 SS、Vmess、VLESS 等协议
- ✏️ **自定义处理**：重命名、去重、区域筛选、脚本处理
- 🎨 **前端界面**：友好的 Web 管理面板
- 📱 **多客户端**：适配 Surge、Clash、Quantumult 等

**官方项目**：
- [后端](https://github.com/sub-store-org/Sub-Store)
- [前端](https://github.com/sub-store-org/Sub-Store-Front-End)

## 前置准备

### 系统要求

- Ubuntu 20.04+ / Debian 11+
- Node.js v20.18.0+
- 4GB 内存，10GB 磁盘空间

### 安装基础工具

```bash
# 更新系统
apt update && apt upgrade -y

# 安装必需工具
apt install unzip curl wget git sudo -y
```

## 部署步骤

### 步骤 1：安装 Node.js（fnm）

使用快速节点管理器 fnm：

```bash
# 安装 fnm
curl -fsSL https://fnm.vercel.app/install | bash

# 加载环境变量
source /root/.bashrc

# 安装指定版本
fnm install v20.18.0

# 验证安装
node -v
```

### 步骤 2：安装包管理器 pnpm

```bash
# 安装 pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

# 加载环境变量
source /root/.bashrc

# 验证安装
pnpm --version
```

### 步骤 3：创建工作目录并下载文件

```bash
# 创建目录
mkdir -p /root/sub-store
cd /root/sub-store

# 下载后端包（最新版本）
curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js

# 下载前端包
curl -fsSL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o dist.zip

# 解压前端文件
unzip dist.zip && mv dist frontend && rm dist.zip

# 验证文件
ls -la
```

### 步骤 4：创建 Systemd 服务

编辑服务配置文件：

```bash
nano /etc/systemd/system/sub-store.service
```

粘贴以下内容：

```ini
[Unit]
Description=Sub-Store Subscription Manager
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
# 文件描述符限制（支持高并发）
LimitNOFILE=32767

Type=simple

# 环境变量配置
Environment="SUB_STORE_FRONTEND_PATH=/root/sub-store/frontend"
Environment="SUB_STORE_FRONTEND_HOST=0.0.0.0"
Environment="SUB_STORE_FRONTEND_PORT=3001"

Environment="SUB_STORE_BACKEND_API_HOST=127.0.0.1"
Environment="SUB_STORE_BACKEND_API_PORT=3000"

# 数据存储路径
Environment="SUB_STORE_DATA_BASE_PATH=/root/sub-store"

# API 路径（自定义，用于隐藏后端）
Environment="SUB_STORE_FRONTEND_BACKEND_PATH=/9GgGyhWFEguXZBT3oHPY"

# 自动更新计划（每天午夜）
Environment="SUB_STORE_BACKEND_CRON=0 0 * * *"

# 运行命令
ExecStartPre=/bin/sh -c "ulimit -n 51200"
ExecStart=/root/.local/share/fnm/fnm exec --using v20.18.0 node /root/sub-store/sub-store.bundle.js

# 运行用户
User=root
Group=root

# 自动重启
Restart=on-failure
RestartSec=5s

# 日志输出
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 步骤 5：启动服务

```bash
# 重载 systemd 配置
systemctl daemon-reload

# 启动服务
systemctl start sub-store.service

# 设为开机自启
systemctl enable sub-store.service

# 查看服务状态
systemctl status sub-store.service

# 查看实时日志
journalctl -u sub-store.service -f
```

## 服务管理

### 常用命令

```bash
# 启动服务
systemctl start sub-store.service

# 停止服务
systemctl stop sub-store.service

# 重启服务
systemctl restart sub-store.service

# 查看状态
systemctl status sub-store.service

# 查看日志（最后 100 行）
journalctl -u sub-store.service -n 100

# 实时日志
journalctl -u sub-store.service -f
```

## 配置说明

### 访问前端

首次访问时需要指定后端地址：

```
http://IP:3001/?api=http://IP:3001/9GgGyhWFEguXZBT3oHPY
```

或者设置书签，以后直接访问：

```
http://IP:3001
```

### 环境变量说明

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `SUB_STORE_FRONTEND_PORT` | 前端端口 | 3001 |
| `SUB_STORE_BACKEND_API_PORT` | 后端 API 端口 | 3000 |
| `SUB_STORE_DATA_BASE_PATH` | 数据保存目录 | /root/sub-store |
| `SUB_STORE_FRONTEND_BACKEND_PATH` | 后端隐藏路径 | /9GgGyhWFEguXZBT3oHPY |
| `SUB_STORE_BACKEND_CRON` | 订阅自动更新周期 | 0 0 * * * |

### 添加反向代理（Nginx）

如需通过域名访问，配置 Nginx：

```nginx
server {
    listen 80;
    server_name sub-store.example.com;

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
    }

    location /9GgGyhWFEguXZBT3oHPY {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
    }
}
```

重载 Nginx：

```bash
nginx -t
systemctl reload nginx
```

## 更新步骤

### 更新后端和前端

```bash
# 停止服务
systemctl stop sub-store.service

# 进入目录
cd /root/sub-store

# 备份配置
cp sub-store.bundle.js sub-store.bundle.js.bak
cp -r frontend frontend.bak

# 下载最新版本
curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js
curl -fsSL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o dist.zip

# 解压前端
unzip -o dist.zip && mv dist frontend && rm dist.zip

# 重载 systemd 配置
systemctl daemon-reload

# 启动服务
systemctl start sub-store.service

# 查看状态
systemctl status sub-store.service
```

## 常见问题

### Q：无法连接到后端 API

A：检查以下几点：
1. 后端是否启动：`systemctl status sub-store.service`
2. 确保 API 路径配置正确
3. 查看日志：`journalctl -u sub-store.service -f`

### Q：订阅更新失败

A：可能原因及解决：
1. 网络连接：检查服务器是否能访问订阅源
2. 源地址有效性：验证订阅 URL 格式
3. 查看日志中的错误信息

### Q：前端打不开

A：尝试以下方法：
1. 检查端口是否开放：`curl http://localhost:3001`
2. 确认防火墙规则
3. 清除浏览器缓存重试

### Q：导出订阅时出错

A：确保：
1. 后端运行正常
2. API 路径设置正确（URL 中包含 `/9GgGyhWFEguXZBT3oHPY`）
3. 检查文件权限：`ls -la /root/sub-store`

## 进阶配置

### 自定义重命名脚本

使用开源脚本库进行节点重命名：

```
https://raw.githubusercontent.com/Keywos/rule/main/rename.js
```

在 Sub-Store 管理面板中的"处理器"→"脚本"中添加此脚本链接。

### 订阅源示例

常用的公开订阅聚合源（仅供参考）：

- Airport：https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity
- Leon：https://raw.githubusercontent.com/Leon406/SubCrawler/main/sub/share/vless
- AutoMergePublicNodes：https://raw.githubusercontent.com/chengaopan/AutoMergePublicNodes/main/snippets/nodes.yml

---

**最后更新**：2024-12-15