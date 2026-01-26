# dnsdist - DNS 负载均衡器

基于 Debian 12 安装和配置 **dnsdist 1.8** 的完整教程。

## 目录

- [重要说明](#重要说明)
- [环境准备](#环境准备与依赖安装)
- [添加软件仓库](#添加-powerdns-软件仓库)
- [安装 dnsdist](#安装-dnsdist)
- [配置文件](#配置-dnsdist)
- [启动服务](#启动与验证服务)

## 重要说明

⚠️ 本教程假设您已使用 **root** 用户登录或通过 `su` 命令切换到 root 权限执行操作，因此所有命令均**未加 sudo**。

## 环境准备与依赖安装

首先，更新系统软件包列表并安装所需的依赖工具：

```bash
apt update && apt upgrade -y
apt install -y curl gnupg2 lsb-release ca-certificates
```

## 添加 PowerDNS 软件仓库

dnsdist 由 PowerDNS 维护。为了安装特定版本的 dnsdist 1.8，需要添加其官方软件源。

### 步骤 A: 导入 GPG 密钥

```bash
curl https://repo.powerdns.com/FD380FBB-pub.asc | gpg --dearmor -o /usr/share/keyrings/pdns-archive-keyring.gpg
```

### 步骤 B: 添加软件源

```bash
echo "deb [signed-by=/usr/share/keyrings/pdns-archive-keyring.gpg] https://repo.powerdns.com/debian $(lsb_release -c -s)-dnsdist-20 main" | tee /etc/apt/sources.list.d/dnsdist.list
```

### 步骤 C: 更新软件包列表

```bash
apt update
```

## 安装 dnsdist

```bash
apt install dnsdist -y
```

## 配置 dnsdist

编辑配置文件：

```bash
nano /etc/dnsdist/dnsdist.conf
```

将以下内容粘贴到配置文件中：

```lua
-- =========================================================
-- dnsdist 2.0.1 兼容配置 (极简且稳定)
-- 目的：实现监听、转发、轮询和故障自动切换
-- =========================================================

-- 1. 监听端口
setLocal("0.0.0.0:53", {reusePort=true})

-- 2. 上游递归服务器配置
-- retries=1 允许在第一次查询超时/失败后，自动切换到另一台服务器
newServer({
    address="192.168.1.10",
    name="unbound",
    sockets = 4, 
    maxInFlight = 200,
    retries=1
})

newServer({
    address="192.168.1.11",
    name="pdns",
    sockets = 4, 
    maxInFlight = 200,
    retries=1
})

-- 3. 转发策略
-- 使用内置的轮询策略
setServerPolicy(roundrobin)

-- 4. 缓存
pc = newPacketCache(10000, {maxTTL=86400})
getPool(""):setCache(pc)

-- 5. 控制接口和 Web 界面
addACL("127.0.0.1")
addACL("192.168.1.0/24")

controlSocket("127.0.0.1:5199")

setWebserverConfig{
    password = 'admin123',
    acl      = '127.0.0.1,192.168.1.0/24'
}
webserver("0.0.0.0:8080")
```

## 启动与验证服务

设置开机自启并启动服务，最后检查状态：

```bash
systemctl enable dnsdist
systemctl start dnsdist
systemctl status dnsdist
```