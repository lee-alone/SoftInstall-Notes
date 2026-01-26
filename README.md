# 软件安装与系统优化笔记

这是一份全面的 Linux 系统软件安装、配置和优化指南集合，涵盖了网络服务、系统优化、密钥管理等多个领域。

## 📂 项目结构

```
SoftInstall-Notes/
├── dns/                          # DNS 服务配置指南
│   ├── README.md                # DNS 完整指南入口
│   ├── dnsdist.md               # DNS 负载均衡器
│   ├── unbound.md               # 递归 DNS 解析服务器
│   ├── pdns.md                  # PowerDNS Recursor
│   └── dnsmasq.md               # DNS 缓存与 DHCP 服务
├── KMS/                         # 密钥管理系统
│   └── vlmcsd.md                # Windows KMS 激活服务
├── NTP/                         # 时间同步服务
│   └── ntp.md                   # NTP 服务配置
├── speedtest/                   # 网络测速工具
│   └── speedtest.md             # Speedtest 部署
├── sub-store/                   # 订阅管理工具
│   ├── sub-store install.md     # 安装指南
│   └── sub-store_data.json      # 配置示例
├── pve优化/                     # Proxmox VE 优化
│   ├── openwrt中继ipv6/         # OpenWrt IPv6 中继
│   ├── pve中的openwrt设置/      # PVE 中 OpenWrt 配置
│   ├── udp优化/                 # UDP 优化指南
│   ├── 主机硬盘优化寿命/         # 硬盘寿命优化
│   └── openwrt/                 # OpenWrt 相关
│       └── 快速编译/             # 快速编译指南
└── windows set/                 # Windows 系统设置
    ├── win adjust copy buffer.bat    # 复制缓冲优化脚本
    └── win11关于ipv6问题/           # Windows 11 IPv6 问题
```

## 🚀 快速导航

### 🔌 网络服务
- **[DNS 完整指南](dns/README.md)** - 多种 DNS 解决方案对比与部署
  - [dnsdist 负载均衡](dns/dnsdist.md) - DNS 转发、故障转移
  - [Unbound 递归解析](dns/unbound.md) - 本地 DNS 递归服务
  - [PowerDNS Recursor](dns/pdns.md) - 高性能递归解析
  - [dnsmasq 配置](dns/dnsmasq.md) - OpenWrt DNS 与 DHCP

### 🔐 系统管理
- **[KMS 激活服务](KMS/vlmcsd.md)** - Windows 批量激活部署
- **[NTP 时间同步](NTP/ntp.md)** - 网络时间协议配置

### 📊 系统优化
- **[Proxmox VE 优化](pve优化/)** - 虚拟化性能调优
  - IPv6 中继与配置
  - UDP 性能优化
  - 硬盘寿命管理
  - OpenWrt 集成

- **[Windows 系统设置](windows%20set/)** - Windows 系统微调
  - 复制缓冲优化
  - IPv6 问题解决

### 🛠️ 工具与应用
- **[Speedtest 部署](speedtest/)** - 网络测速服务
- **[sub-store 订阅管理](sub-store/)** - 订阅统一管理工具

## 📖 主要特性

✅ **实用性强** - 所有配置都经过实际测试  
✅ **结构清晰** - 分类详细，易于查找  
✅ **Markdown 格式** - GitHub 友好的文档格式  
✅ **多版本支持** - 涵盖不同系统版本的配置  
✅ **配置示例** - 包含完整的配置代码  
✅ **故障排查** - 常见问题与解决方案  

## 🎯 使用指南

### 查找相关内容

1. **通过目录结构浏览** - 查看 `dns/`、`pve优化/` 等主要分类
2. **通过快速导航查找** - 使用上面的快速导航链接
3. **查看 README** - 每个文件夹都有 `README.md` 入口指南

### 阅读文档

每份文档都遵循统一格式：

```
标题
├── 简介
├── 目录
├── 前置说明
├── 安装步骤
├── 配置说明
├── 启动服务
├── 高级配置
└── 常见问题
```

### 复制配置

配置代码都在专门的代码块中，方便复制：

```bash
# 标明了系统和环境要求
# 代码可直接复制运行
```

## 💡 推荐阅读路径

### 初学者
1. 选择需要的服务（如 DNS）
2. 阅读该服务的 README.md 了解概况
3. 选择合适的实现方案
4. 按步骤执行配置

### 进阶用户
1. 参考多服务组合方案
2. 查看高级配置部分
3. 根据需求定制配置
4. 参考故障排查章节

## 🔍 快速搜索

### 如果你想...

| 任务 | 相关文档 |
|------|--------|
| 搭建 DNS 服务 | [dns/README.md](dns/README.md) |
| 配置 Unbound | [dns/unbound.md](dns/unbound.md) |
| 设置 DNS 负载均衡 | [dns/dnsdist.md](dns/dnsdist.md) |
| 优化 OpenWrt | [pve优化/](pve优化/) |
| 激活 Windows | [KMS/vlmcsd.md](KMS/vlmcsd.md) |
| 同步网络时间 | [NTP/ntp.md](NTP/ntp.md) |

## 📝 文档规范

所有文档遵循以下规范：

- ✅ 使用 Markdown 格式
- ✅ 包含清晰的目录导航
- ✅ 代码块标明语言（bash, conf, lua 等）
- ✅ 重要提示使用图标标记（⚠️, ✅, ❌ 等）
- ✅ 支持 GitHub 原生渲染
- ✅ 中英文使用规范

## 🐛 常见问题

### Q: 这些配置适用于哪些系统？
**A:** 主要针对 Linux（特别是 Debian 系）和 OpenWrt，部分内容适用于 Windows。详见各文档的系统要求。

### Q: 配置能直接复制运行吗？
**A:** 大部分可以，但建议先理解配置内容。某些IP地址、路径需要根据实际环境调整。

### Q: 如果按照文档出问题了怎么办？
**A:** 查看各文档的故障排查章节，或参考该软件的官方文档。

### Q: 如何贡献新的文档？
**A:** 欢迎提交 Pull Request。请遵循现有的 Markdown 格式和文档结构。

## 📚 参考资源

| 服务 | 官方网站 |
|------|--------|
| Unbound | https://nlnetlabs.nl/projects/unbound/ |
| PowerDNS | https://www.powerdns.com/ |
| dnsdist | https://dnsdist.org/ |
| dnsmasq | http://www.thekelleys.org.uk/dnsmasq/ |
| Proxmox VE | https://www.proxmox.com/ |
| OpenWrt | https://openwrt.org/ |

## 📄 许可证

这个项目的内容可自由使用和分享。

## 👤 维护信息

- **最后更新**：2024-12-15
- **维护者**：DNS 配置团队
- **贡献者**：欢迎提交改进建议

---

**开始探索吧！** 👉 [查看 DNS 完整指南](dns/README.md)

如有问题或改进建议，欢迎反馈！