# Speedtest 网速测试

自建网速测试服务的部署和配置。

## 📋 文件清单

| 文件 | 描述 |
|------|------|
| [speedtest.md](speedtest.md) | LibreSpeed 完整部署指南 |

## 🚀 快速开始

### 一键部署

```bash
# 1. 安装 Web 服务器
apt install nginx -y

# 2. 克隆 LibreSpeed
git clone https://github.com/librespeed/speedtest.git
cd speedtest

# 3. 复制文件
cp index.html speedtest.js speedtest_worker.js favicon.ico /var/www/html/
cp -r backend /var/www/html/

# 4. 启动服务
systemctl start nginx
systemctl enable nginx
```

### 访问测试

```
http://your-server-ip/
```

## 📊 功能特性

- ⚡ 下载速度测试
- 📤 上传速度测试
- 📡 延迟和抖动测试
- 💾 测试结果保存
- 🔒 支持 HTTPS
- 📱 响应式设计

---

**最后更新**：2024-12-15