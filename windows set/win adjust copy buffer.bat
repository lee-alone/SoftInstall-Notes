@echo off
echo 检查 LargeSystemCache 是否存在...
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache
if %errorlevel%==0 (
    echo LargeSystemCache 存在，设置值为 1...
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
) else (
    echo LargeSystemCache 不存在，创建并设置值为 1...
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
)
echo 将读取缓冲区大小更改为 512MB...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Size /t REG_DWORD /d 524288 /f
echo 完成。请重新启动计算机以使更改生效。
pause
