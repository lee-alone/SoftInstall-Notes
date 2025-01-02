### debian拉取安装包
apt install ntp <br>

### 编辑配置文件
nano /etc/ntpsec/ntp.conf <br>

### server加入服务器
server ntp.ntsc.ac.cn<br>
server cn.ntp.org.cn<br>
server ntp1.aliyun.com<br>
server ntp2.aliyun.com<br>
server ntp.tuna.tsinghua.edu.cn<br>
server ntp.ustc.edu.cn<br>


### 测试命令 
w32tm /stripchart /computer:192.168.1.100<br>
-d 网络延时  -o 时间延时<br>
### Linux查看运行状态
ntpq -p 


