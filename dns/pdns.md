### 1. 安装 pdns-recursor

# 更新软件包列表并安装 pdns-recursor
apt update
apt install pdns-recursor -y

# 检查服务状态（此时服务可能启动失败，因为端口冲突，在第 7 步解决）
systemctl status pdns-recursor

###2. 配置 pdns-recursor

使用 nano 编辑 pdns-recursor 的配置文件。

nano /etc/powerdns/recursor.conf

# 请在文件中添加或修改以下配置项：

refresh-on-ttl-perc=10
local-address=0.0.0.0
local-port=53  # 注意：这里将端口改为 5353，以避免与 dnsdist 的 53 端口冲突
allow-from=127.0.0.0/8, <你的局域网网段>/<掩码> # 限制访问

### 3. 重新启动 pdns-recursor 服务

# 重新启动服务以应用新的配置
systemctl restart pdns-recursor

# 检查服务状态，确保其已正常运行
systemctl status pdns-recursor
