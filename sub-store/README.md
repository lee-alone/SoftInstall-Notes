# Sub-Store 订阅管理

自建订阅聚合、转换和管理服务。

## 📋 文件清单

| 文件 | 描述 |
|------|------|
| [sub-store.md](sub-store.md) | 完整部署和配置指南 |
| [sub-store_data.json](sub-store_data.json) | 订阅配置示例（参考） |

## 🚀 快速开始

### 一键部署

```bash
# 1. 安装 Node.js
curl -fsSL https://fnm.vercel.app/install | bash
source /root/.bashrc
fnm install v20.18.0

# 2. 安装包管理器
curl -fsSL https://get.pnpm.io/install.sh | sh -
source /root/.bashrc

# 3. 创建目录并下载文件
mkdir -p /root/sub-store
cd /root/sub-store
curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js
curl -fsSL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o dist.zip
unzip dist.zip && mv dist frontend && rm dist.zip

# 4. 创建服务并启动
# 参考 sub-store.md 中的 systemd 配置
systemctl start sub-store.service
```

### 访问前端

```
http://your-ip:3001/?api=http://your-ip:3001/9GgGyhWFEguXZBT3oHPY
```

## 🎯 主要功能

- 📦 **聚合订阅源**：支持多个订阅源合并
- 🔄 **协议转换**：SS、Vmess、VLESS 格式转换
- ✏️ **自定义处理**：重命名、去重、筛选、脚本处理
- 🌍 **区域筛选**：按地区筛选节点
- 🔗 **反向代理**：支持 Nginx 代理部署

## 📝 配置示例

### 订阅聚合

在 Sub-Store 中创建聚合订阅：

```json
{
  "name": "All Nodes",
  "subscriptions": ["airport", "leon", "pawdroid"],
  "process": [
    {"type": "Handle Duplicate Operator"},
    {"type": "Region Filter", "args": ["US", "JP"]},
    {"type": "Type Filter", "args": ["vless", "vmess"]}
  ]
}
```

---

**最后更新**：2024-12-15