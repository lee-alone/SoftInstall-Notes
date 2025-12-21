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

5.0以上系统使用如下配置：

dnssec:
  validation: process  # 推荐保留，启用 DNSSEC 验证
  trustanchorfile: /usr/share/dns/root.key

recursor:
  hint_file: /usr/share/dns/root.hints
  include_dir: /etc/powerdns/recursor.d
  security_poll_suffix: ''

incoming:
  listen:
    - 0.0.0.0  # 监听所有 IPv4 接口（你的服务器公网/内网 IP）
    - '::'     # 监听所有 IPv6 接口（如果服务器支持 IPv6，可选保留）
  allow_from:
    - 192.168.1.0/24  # 只允许你的网段查询（包括 192.168.1.1）
    - 127.0.0.0/8     # 推荐保留本地回环
    - ::1/128         # 如果需要 IPv6 本地回环

outgoing:
  source_address:
    - 0.0.0.0  # 默认，可保留（从可用接口选择源 IP）
