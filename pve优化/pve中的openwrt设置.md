# PVE 中 OpenWrt 设置指南

在 Proxmox VE 虚拟化环境中正确配置和优化 OpenWrt 虚拟机。

## 目录

- [磁盘配置](#磁盘配置)
- [磁盘优化参数](#磁盘优化参数)
- [软件层面优化](#软件层面优化)
- [最佳实践](#最佳实践)

## 磁盘配置

### 推荐配置表

| 项目 | 推荐设置 | 原因 |
|------|---------|------|
| **缓存模式** | 写回（Write Back） | 减少每次写入硬盘，延长寿命 |
| **异步 IO** | io_uring（保持） | 性能优良 |
| **SSD 仿真** | 根据实际磁盘选择 | SSD 提高虚拟机 I/O 效率 |
| **跳过复制** | 勾选 | 减少不必要写入 |
| **备份** | 保留或按需求 | 备份增加写入，必要时可关 |

### 配置步骤

1. 在 PVE 控制台选中 OpenWrt 虚拟机
2. 进入 **硬件** 选项卡
3. 选中磁盘，点击 **编辑**
4. 配置以下参数：
   - **缓存**：选择 **写回（Write Back）**
   - **禁用 COW**：勾选（如果有）
   - **SSD 仿真**：如果底层存储是 SSD，勾选

## 磁盘优化参数

### 写缓存配置

**写回模式（Write Back）** 的效果：
- 虚拟机写入数据时，数据先写入缓存
- 定期或到达阈值后才刷入磁盘
- 大幅减少磁盘 I/O 次数

**性能提升**：约 2-3 倍的写入吞吐量

### I/O 调度器选择

在 OpenWrt 虚拟机内部，可进一步优化 I/O 调度：

```bash
# 查看当前 I/O 调度器
cat /sys/block/vda/queue/scheduler

# 切换到 noop（虚拟化环境下推荐）
echo noop > /sys/block/vda/queue/scheduler
```

## 软件层面优化

### 方案 1：使用 tmpfs 挂载临时目录

#### 原理

OpenWrt 默认将 `/tmp` 挂载为内存盘（tmpfs），但日志（如 syslog）可能仍写入磁盘。将这些数据移到 tmpfs 后，它们仅存于 RAM，重启丢失，但能大幅减少磁盘写入。

**成品路由器常用此法延长闪存寿命。**

#### 配置步骤

通过 SSH 或 LuCI 登录 OpenWrt，编辑 `/etc/fstab`：

```bash
nano /etc/fstab
```

添加以下行：

```fstab
tmpfs /tmp tmpfs defaults,noatime,size=256M 0 0
tmpfs /var/log tmpfs defaults,noatime,size=128M 0 0
```

**参数说明**：
- `noatime`：禁用访问时间记录，进一步减少写入
- `size=256M`：限制 `/tmp` 占用内存大小（根据可用内存调整）

重启或手动挂载：

```bash
mount -a
```

验证配置：

```bash
df -h | grep tmpfs
```

### 方案 2：优化日志配置

#### 原理

日志是常见的写入源（dnsmasq、firewall 日志等）。降低日志级别或重定向到 RAM/远程，能减少 80% 以上的磁盘写入。

#### 步骤 1：限制日志大小

编辑日志配置：

```bash
nano /etc/config/system
```

修改以下参数：

```ini
option log_size '64'        # 限制日志文件大小（KB）
option log_file '/var/log/messages'  # 配合 tmpfs，确保在 RAM
```

#### 步骤 2：降低日志级别

在 `/etc/config/system` 添加：

```ini
option log_level 'warn'  # 只记录警告以上级别，减少琐碎日志
```

**日志级别说明**：
- `debug`：最详细，包含所有信息
- `info`：标准信息
- `notice`：通知级别
- `warn`：警告及以上（推荐用于生产环境）
- `err`：仅记录错误

#### 步骤 3：配置远程 syslog（可选）

如果需要持久化日志记录：

```bash
# 安装 syslog-ng
opkg update && opkg install syslog-ng
```

编辑 `/etc/syslog-ng/syslog-ng.conf`，添加远程目标：

```
destination remote { udp("192.168.1.100" port(514)); };
log { source(src); destination(remote); };
```

重启服务：

```bash
/etc/init.d/syslog-ng restart
```

### 方案 3：挂载选项优化

#### 原理

默认挂载会记录文件访问时间（atime），每次读文件都会引发小写入。禁用它几乎无性能损失，但能显著减少写入，尤其在路由器的高频文件访问中。

#### 配置步骤

编辑 `/etc/fstab`，为根分区（通常 `/overlay`）添加选项：

```fstab
/dev/root /overlay ext4 rw,noatime,nodiratime 0 0
```

重新挂载：

```bash
mount -o remount,noatime,nodiratime /overlay
```

#### 验证配置

```bash
mount | grep overlay
```

输出应包含 `noatime,nodiratime` 选项。

## 最佳实践

### 1. 监控磁盘寿命

```bash
# 查看 SSD 健康状态（如果磁盘支持）
smartctl -a /dev/vda
```

### 2. 定期清理日志

创建 cron 任务定期清理临时文件：

```bash
# 编辑 crontab
crontab -e

# 添加每周清理日志的任务
0 0 * * 0 rm -f /tmp/*.log
```

### 3. 优化的完整配置

综合以上方案，理想的 OpenWrt 在 PVE 中的配置应包含：

| 优化项 | 效果 | 实施难度 |
|--------|------|----------|
| PVE 磁盘写回缓存 | 减少主机磁盘 I/O | 简单 |
| tmpfs 临时目录 | 大幅减少虚拟机磁盘写入 | 简单 |
| 日志级别降低 | 减少日志写入 | 简单 |
| 远程 syslog | 保留日志但减少本地写入 | 中等 |
| 挂载选项优化 | 进一步减少写入 | 简单 |

## 常见问题

### Q: 配置 tmpfs 后，重启前的日志会丢失吗？
**A:** 是的，tmpfs 中的数据在系统重启或宕机后丢失。如果需要保留日志，使用远程 syslog 方案。

### Q: 能否同时使用多个优化方案？
**A:** 完全可以。实际上建议同时使用 tmpfs + 日志优化 + 挂载选项优化，效果最佳。

### Q: OpenWrt 虚拟机的内存应该分配多少？
**A:** 建议至少 512MB，如果启用了 tmpfs 和缓存，建议 1GB 或以上。

---

**最后更新**：2024-12-15