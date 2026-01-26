# Speedtest 网速测试服务部署

使用 LibreSpeed 在自建服务器上部署网速测试服务。

## 目录

- [快速开始](#快速开始)
- [完整部署](#完整部署)
- [配置说明](#配置说明)
- [访问测试](#访问测试)

## 快速开始

### 前置条件

- Ubuntu 20.04+ / Debian 11+
- 已安装 Nginx 或 Apache
- 公网 IP（可选，内网可访问）

### 一键安装

```bash
# 更新系统
apt update && apt upgrade -y

# 安装 Nginx（推荐）
apt install nginx -y

# 或安装 Apache + PHP（备选）
apt install apache2 php libapache2-mod-php -y
```

## 完整部署

### 步骤 1：克隆 LibreSpeed 项目

```bash
# 克隆官方仓库
git clone https://github.com/librespeed/speedtest.git

# 进入项目目录
cd speedtest
```

### 步骤 2：复制文件到 Web 根目录

```bash
# 对于 Nginx，Web 根目录为 /var/www/html
# 对于 Apache，Web 根目录同样为 /var/www/html

# 复制必需的文件和目录
cp index.html /var/www/html/
cp speedtest.js /var/www/html/
cp speedtest_worker.js /var/www/html/
cp favicon.ico /var/www/html/
cp -r backend /var/www/html/
```

### 步骤 3：设置权限

```bash
# 设置 Web 目录权限
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
```

### 步骤 4：启动 Web 服务

**Nginx：**

```bash
# 启动 Nginx
systemctl start nginx
systemctl enable nginx

# 验证状态
systemctl status nginx
```

**Apache：**

```bash
# 启动 Apache
systemctl start apache2
systemctl enable apache2

# 验证状态
systemctl status apache2
```

## 配置说明

### 修改服务端配置

编辑 `backend/config.php`（如果存在）：

```php
<?php
// 服务器配置示例
$maxFileSize = 10000000;  // 最大文件大小，单位：字节
$ulPath = 'upload/';      // 上传文件保存目录
$dbFile = 'speedtest.db'; // SQLite 数据库文件
?>
```

### Nginx 配置示例

编辑 `/etc/nginx/sites-available/default`：

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        # 若需要 PHP 支持，配置 PHP-FPM
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
```

重新加载配置：

```bash
nginx -t
systemctl reload nginx
```

## 访问测试

### 在浏览器中访问

```
http://your-server-ip/
http://your-domain.com/
```

### 测试功能

1. **下载速度测试**：测量客户端下载速度
2. **上传速度测试**：测量客户端上传速度
3. **延迟测试**：ping 和 jitter 测试
4. **数据保存**：自动保存测试结果到服务器数据库

## 常见问题

### Q：无法访问测试页面

A：检查以下几点：
- Nginx/Apache 是否运行：`systemctl status nginx`
- 防火墙是否开放 80 端口：`ufw allow 80`
- 文件是否复制正确：`ls -la /var/www/html/`

### Q：上传测试失败

A：确保 backend 目录有写权限：
```bash
chmod -R 755 /var/www/html/backend
chmod -R 777 /var/www/html/backend/upload
```

### Q：如何启用 HTTPS

A：使用 Certbot 配置 SSL：
```bash
apt install certbot python3-certbot-nginx -y
certbot --nginx -d your-domain.com
systemctl reload nginx
```

## 性能优化

### 启用 Gzip 压缩

在 Nginx 配置中添加：

```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/javascript application/javascript;
```

### 优化上传大小限制

对于 Nginx（编辑 `/etc/nginx/nginx.conf`）：

```nginx
http {
    client_max_body_size 100M;
}
```

对于 Apache（编辑 `/etc/apache2/apache2.conf`）：

```apache
LimitRequestBody 104857600
```

---

**最后更新**：2024-12-15