# PVE 网络和系统性能优化

Proxmox VE (PVE) 系统与网络性能优化教程，针对网络吞吐量（特别是 DNS 服务、高并发 TCP 连接）和系统资源限制的深度优化。

## 目录

- [内核参数优化](#1-内核参数优化-sysctl)
- [系统资源限制](#2-系统资源限制优化-limitsconf)
- [Systemd 配置](#3-systemd-系统配置)
- [LXC 容器优化](#4-lxc-容器特殊优化)
- [硬件优化](#5-硬件与底层进阶优化)
- [优化总结](#优化总结)

## 1. 内核参数优化 (sysctl)

通过调整内核参数，可以显著减少高并发下的丢包现象，并提高网络协议栈的处理能力。

### 步骤 1：创建配置文件

```bash
nano /etc/sysctl.d/99-performance.conf
```

### 步骤 2：添加配置内容

将以下参数复制并粘贴到文件中：

```ini
# 网络缓冲区优化
net.core.rmem_max = 26214400
net.core.wmem_max = 26214400
net.core.rmem_default = 26214400
net.core.wmem_default = 26214400

# 网络队列优化
net.core.netdev_max_backlog = 4096
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096

# IP 分片优化
net.ipv4.ipfrag_high_thresh = 2621440
net.ipv4.ipfrag_low_thresh = 1966080

# TCP 连接优化
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000

# 拥塞控制算法（BBR）
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# 内存和缓存
vm.swappiness = 10
vm.vfs_cache_pressure = 50
```

### 参数说明

| 参数 | 值 | 说明 |
|------|-----|------|
| `rmem_max` | 26214400 | TCP 接收缓冲区最大值（~25MB） |
| `wmem_max` | 26214400 | TCP 发送缓冲区最大值（~25MB） |
| `netdev_max_backlog` | 4096 | 网卡接收队列长度 |
| `somaxconn` | 4096 | 服务器监听队列最大值 |
| `tcp_tw_reuse` | 1 | 允许重用 TIME_WAIT 状态连接 |
| `tcp_congestion_control` | bbr | 使用 BBR 拥塞控制算法 |
| `swappiness` | 10 | 降低 swap 使用倾向 |

### 步骤 3：应用配置

```bash
sysctl --system
```

验证配置是否生效：

```bash
sysctl net.ipv4.tcp_congestion_control
```

## 2. 系统资源限制优化 (limits.conf)

为了支持大量文件句柄和并发连接，需要调高系统的文件描述符限制。

### 步骤 1：编辑限制文件

```bash
nano /etc/security/limits.conf
```

### 步骤 2：添加配置

在文件末尾添加以下内容：

```text
* soft nofile 200000
* hard nofile 200000
* soft nproc 200000
* hard nproc 200000
```

**参数说明**：
- `nofile`：最大打开文件数
- `nproc`：最大进程数
- `soft`：软限制（可超出，但会收到警告）
- `hard`：硬限制（不能超出）
- `*`：对所有用户生效

### 步骤 3：验证配置

```bash
# 重新登录后查看
ulimit -n
```

应该显示 200000。

## 3. Systemd 系统配置

确保 Systemd 服务在全局范围内拥有足够的资源分配。

### 步骤 1：编辑 system.conf

```bash
nano /etc/systemd/system.conf
```

### 步骤 2：修改配置

找到或添加以下两项，修改为：

```ini
DefaultLimitNOFILE=200000
DefaultTasksMax=infinity
```

### 步骤 3：重新加载配置

```bash
systemctl daemon-reexec
```

## 4. LXC 容器特殊优化

如果服务运行在 LXC 容器（如 Docker、DNS 等）中，可以解除一些权限限制以提升性能。

### 步骤 1：查找容器配置文件

容器配置文件位于：`/etc/pve/lxc/[容器ID].conf`

### 步骤 2：编辑配置文件

将 `<CTID>` 替换为你的容器 ID（例如 `101`）：

```bash
nano /etc/pve/lxc/<CTID>.conf
```

### 步骤 3：添加配置

在文件末尾添加：

```ini
lxc.apparmor.profile: unconfined
lxc.cap.drop:
```

> ⚠️ **警告**：`unconfined` 会降低容器的隔离安全性，仅在受信任的内部服务环境使用。

## 5. 硬件与底层进阶优化

### 5.1 CPU 性能模式

PVE 默认使用 `powersave` 模式。切换为 `performance` 模式可降低延迟：

```bash
# 安装工具
apt install cpufrequtils -y

# 设置所有核心为性能模式
for i in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do 
  echo "performance" > "$i"
done
```

验证配置：

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

### 5.2 ZFS 内存限制

如果使用 ZFS 存储，它默认占用 50% 物理内存，可能导致容器崩溃：

```bash
# 限制 ZFS ARC 缓存最大为 8GB（根据总内存调整）
echo "options zfs zfs_arc_max=8589934592" > /etc/modprobe.d/zfs.conf

# 更新 initramfs
update-initramfs -u

# 重启生效
reboot
```

**参数换算**（ZFS 内存限制）：
- 2GB = 2147483648
- 4GB = 4294967296
- 8GB = 8589934592
- 16GB = 17179869184

### 5.3 关闭 CPU 安全补丁（慎用）

仅在纯内网环境且追求极致性能时使用，CPU 性能可提升 5%~15%：

```bash
# 编辑 Grub 配置
nano /etc/default/grub

# 找到 GRUB_CMDLINE_LINUX_DEFAULT，在引号内添加：mitigations=off
# 例如改成：GRUB_CMDLINE_LINUX_DEFAULT="quiet mitigations=off"

# 更新 Grub 并重启
update-grub
reboot
```

> ⚠️ **警告**：关闭安全补丁会降低系统安全性。仅在完全隔离的内网环境使用。

## 优化总结

### 优化效果对比

| 优化项 | 性能提升 | 风险等级 | 实施难度 |
|--------|---------|---------|----------|
| 内核参数优化 | 减少丢包 30-50% | 低 | 简单 |
| 文件描述符限制 | 支持 10x 并发 | 低 | 简单 |
| CPU 性能模式 | 降低延迟 5-10% | 低 | 简单 |
| ZFS 内存限制 | 防止 OOM | 低 | 简单 |
| 关闭安全补丁 | CPU 性能 +5-15% | **高** ⚠️ | 简单 |

### 完整部署检查清单

- [ ] 已创建 99-performance.conf 并应用
- [ ] 已编辑 limits.conf 配置文件描述符
- [ ] 已修改 systemd system.conf
- [ ] 已验证 sysctl 和 ulimit 生效
- [ ] （可选）已优化 LXC 容器配置
- [ ] （可选）已切换 CPU 为性能模式
- [ ] （可选）已限制 ZFS 内存占用
- [ ] （可选）已关闭安全补丁（内网环境）

### 重启服务

完成以上优化后，建议重启受影响的服务：

```bash
# 重启受影响的容器或虚拟机
pct reboot <CTID>
qm reboot <VMID>

# 或重启整个 PVE 宿主机（如有内存或引导参数变更）
reboot
```

---

**最后更新**：2024-12-15