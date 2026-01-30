@echo off
setlocal enabledelayedexpansion
:: ================================
:: 配置区（可自定义）
:: ================================
set NTP_SERVERS="192.168.1.10,0x9 time.google.com,0x9 pool.ntp.org,0x9"
set POLL_INTERVAL=900
set LOCAL_DISPERSION=10
set MAX_PHASE_CORRECTION=1800
set LOGFILE=%~dp0w32time_sync.log
echo ================================
echo Windows 时间同步优化脚本（BAT 企业版）
echo ================================
echo.
:: ================================
:: 检查管理员权限
:: ================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本。
    pause
    exit /b 1
)
:: ================================
:: 写日志函数
:: ================================
echo [%date% %time%] 脚本启动 >> "%LOGFILE%"
call :log "使用的 NTP 服务器: %NTP_SERVERS%"
:: ================================
:: 检查 NTP 服务器可达性
:: ================================
echo [%date% %time%] 开始检查 NTP 服务器可达性 >> "%LOGFILE%"
for %%s in (%NTP_SERVERS:"=%) do (
    for /f "tokens=1 delims=," %%i in ("%%s") do (
        call :log "测试服务器 %%i ..."
        ping -n 1 -w 800 %%i >nul 2>&1
        if !errorlevel! equ 0 (
            call :log "服务器 %%i 可达 (ping 通)"
        ) else (
            call :log "警告：服务器 %%i 不可达 (ping 超时或失败，可能网络问题或防火墙阻挡 UDP 123)"
        )
    )
)
:: ================================
:: 停止服务
:: ================================
call :log "停止 W32Time 服务"
net stop w32time >nul 2>&1 || call :log "警告：停止服务失败（可能已停止）"
:: ================================
:: 备份旧配置
:: ================================
call :log "备份旧配置到 w32time_backup.reg"
reg export HKLM\SYSTEM\CurrentControlSet\Services\W32Time "%~dp0w32time_backup.reg" /y >nul || call :log "备份失败！"
:: ================================
:: 配置 NTP
:: ================================
call :log "应用 NTP 配置"
w32tm /config /manualpeerlist:%NTP_SERVERS% /syncfromflags:manual /reliable:yes /update || call :log "配置命令失败，请检查语法"
:: ================================
:: 注册表优化
:: ================================
call :log "写入注册表优化参数"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" /v SpecialPollInterval /t REG_DWORD /d %POLL_INTERVAL% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v LocalClockDispersion /t REG_DWORD /d %LOCAL_DISPERSION% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v MaxPosPhaseCorrection /t REG_DWORD /d %MAX_PHASE_CORRECTION% /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v MaxNegPhaseCorrection /t REG_DWORD /d %MAX_PHASE_CORRECTION% /f >nul
:: ================================
:: 虚拟机优化（可选）
:: ================================
wmic computersystem get model | find /i "Virtual" >nul
if %errorlevel% equ 0 (
    call :log "检测到虚拟机环境，应用 VM 优化"
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v MinPollInterval /t REG_DWORD /d 6 /f >nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" /v MaxPollInterval /t REG_DWORD /d 10 /f >nul
    call :log "重要：请在 Hyper-V/VMware 设置中关闭 guest 的 '时间同步' Integration Service，否则无效"
)
:: ================================
:: 启动服务
:: ================================
call :log "启动 W32Time 服务"
net start w32time >nul 2>&1 || call :log "启动失败！"
:: ================================
:: 强制同步
:: ================================
call :log "触发强制同步（带 rediscover）"
w32tm /resync /rediscover /force >nul 2>&1
timeout /t 10 >nul
:: ================================
:: 验证同步结果
:: ================================
call :log "验证同步状态（关键行）"
w32tm /query /status > "%~dp0w32time_status.tmp" 2>&1
findstr /i "Source Stratum Leap Indicator Offset Last Successful" "%~dp0w32time_status.tmp"
type "%~dp0w32time_status.tmp" >> "%LOGFILE%"
del "%~dp0w32time_status.tmp" 2>nul
echo.
echo ================================
echo 配置完成！日志已写入：
echo %LOGFILE%
echo 建议运行以下命令进一步验证：
echo   w32tm /query /source
echo   w32tm /query /status
echo   w32tm /monitor
echo ================================
pause
exit /b 0
:: ================================
:: 日志函数
:: ================================
:log
echo [%date% %time%] %~1 >> "%LOGFILE%"
exit /b
