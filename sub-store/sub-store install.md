by pass local-ip
#部署 sub-store

#前端 ：
`https://github.com/sub-store-org/Sub-Store-Front-End`

#后端：
`https://github.com/sub-store-org/Sub-Store`

```
apt update
apt install unzip curl wget git sudo -y
curl -fsSL https://fnm.vercel.app/install | bash
```
```
source /root/.bashrc
```
```
fnm install v20.18.0
```

`node -v `  
# 回显返回版本号即为安装成功
`curl -fsSL https://get.pnpm.io/install.sh | sh -`
`source /root/.bashrc`
`mkdir -p /root/sub-store`
`cd sub-store`
# 拉取后端项目
`curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js`
 
# 拉取前端项目
`curl -fsSL https://github.com/sub-store-org/Sub-Store-Front-End/releases/latest/download/dist.zip -o dist.zip`

`unzip dist.zip && mv dist frontend && rm dist.zip`

`nano /etc/systemd/.system/sub-store.service`
```
[Unit]
Description=Sub-Store
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service
 
[Service]
LimitNOFILE=32767
Type=simple
Environment="SUB_STORE_FRONTEND_BACKEND_PATH=/9GgGyhWFEguXZBT3oHPY"
Environment="SUB_STORE_BACKEND_CRON=0 0 * * *"
Environment="SUB_STORE_FRONTEND_PATH=/root/sub-store/frontend"
Environment="SUB_STORE_FRONTEND_HOST=0.0.0.0"
Environment="SUB_STORE_FRONTEND_PORT=3001"
Environment="SUB_STORE_DATA_BASE_PATH=/root/sub-store"
Environment="SUB_STORE_BACKEND_API_HOST=127.0.0.1"
Environment="SUB_STORE_BACKEND_API_PORT=3000"
ExecStart=/root/.local/share/fnm/fnm exec --using v20.18.0 node /root/sub-store/sub-store.bundle.js
User=root
Group=root
Restart=on-failure
RestartSec=5s
ExecStartPre=/bin/sh -c ulimit -n 51200
StandardOutput=journal
StandardError=journal
 
[Install]
WantedBy=multi-user.target
```
`systemctl start sub-store.service`     
# 启动服务

`systemctl enable sub-store.service`    
# 设置为开机自启

`systemctl status sub-store.service`   
# 查看服务状态

`systemctl stop sub-store.service `     
# 停止服务

`systemctl restart sub-store.service`   
# 重启服务


# 登录
`http://IP:3001/?api=http://IP:3001/9GgGyhWFEguXZBT3oHPY`

# 更新
`systemctl stop sub-store.service  停止服务`
`cd sub-store`             进入 sub-store 文件夹
# 更新项目脚本

`curl -fsSL https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js -o sub-store.bundle.js`

`systemctl daemon-reload   `    重载服务

`systemctl start sub-store.service `  启动服务

`systemctl status sub-store.service`   查看服务状态

# 重命名脚本
'https://raw.githubusercontent.com/Keywos/rule/main/rename.js'
# 开源节点
https://raw.githubusercontent.com/mahdibland/ShadowsocksAggregator/master/Eternity
https://raw.githubusercontent.com/Leon406/SubCrawler/refs/heads/main/sub/share/vless
https://raw.githubusercontent.com/chengaopan/AutoMergePublicNodes/refs/heads/master/snippets/nodes.yml
https://raw.githubusercontent.com/Pawdroid/Free-servers/refs/heads/main/sub
https://raw.githubusercontent.com/aiboboxx/v2rayfree/refs/heads/main/v2
