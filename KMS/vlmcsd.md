### debian 编译前的依赖安装
apt-get update<br>
apt-get install git gcc make -y<br>

### 拉取项目
git clone https://github.com/Wind4/vlmcsd.git

### 进入目录开始编译
cd vlmcsd/
make

### 将编译后的文件复制进系统bin文件夹
cp bin/* /usr/local/bin

### 创建服务
nano /etc/systemd/system/vlmcsd.service<br>
[Unit]<br>
Description=vlmcsd<br>
Wants=network.target<br>
After=syslog.target<br>

[Service]<br>
Type=forking<br>
PIDFile=/var/run/vlmcsd.pid<br>
ExecStart=/usr/local/bin/vlmcsd -l /var/log/vlmcsd.log -p /var/run/vlmcsd.pid<br>

[Install]<br>
WantedBy=multi-user.target<br>



### 重启daemon
systemctl daemon-reload

### 设置服务
systemctl enable vlmcsd   //开机启动<br>
systemctl start vlmcsd  //启动<br>
systemctl stop vlmcsd  //停止<br>
systemctl status vlmcsd  //软件运行状态查询<br>

### 软件名称对应的功能
vlmcsd ---服务器<br>
vlmcs  ---测试端<br>
