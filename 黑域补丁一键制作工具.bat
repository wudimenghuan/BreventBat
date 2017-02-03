@echo off
TITLE 黑域补丁一键制作工具 by iceWindr
color 3f
set batDir=%~dp0
set adb="%batDir%\adb\adb.exe"
set work="%batDir%\work"
if exist %work% ( 
rd /s/q %work%
)
md "%batDir%\work"
echo.
ECHO. =====================================================================
echo.
echo  你即将使用黑域补丁一键制作工具
echo.
echo  联系作者：酷安网（http://www.coolapk.com/）@iceWindr
echo.
echo  为避免出错，工作路径（目录）请勿含有中文及空格，如果存在请修改
echo.
echo  确保你电脑已正确安装python（建议3.5.x版本）及jdk1.8，按任意键继续...
echo.
ECHO. =====================================================================
pause >nul
CLS
echo.
ECHO  ================== 请选择 ==================
echo.
echo  1. 非odex优化版本，services.jar应该在1M以上
echo.
echo  2. odex优化版本（目前仅支持64位系统）
echo.
ECHO  ============================================
set "select="
echo.
set /p select=请选择:
echo.
CLS
if /i '%select%'=='1' goto deodex
if /i '%select%'=='2' goto odex

:deodex
ECHO. ===============================================================
echo.
echo  请将手机的USB调试打开并连接电脑
echo.
echo  即将申请USB调试权限，请留意手机端的提示并授权，按任意键继续...
echo.
ECHO. ===============================================================
pause >nul
CLS
ECHO. =============================================================
echo.
echo  是否看见如下类似提示：
echo.
echo.
echo       List of devices attached
echo       * daemon not running. starting it now on port 5037 *
echo       * daemon started successfully *
echo       d6fb078b        device
echo.
echo.
echo  如果看到以上提示，说明手机与电脑连接正常，请按任意键继续...
echo.
echo  否则请关闭此窗口，检查驱动是否正确安装，手机是否正确连接
echo.
ECHO. =============================================================
echo.
%adb% devices
pause >nul
CLS
echo.
echo  正在提取system/framework/services.jar到PC...
echo.
%adb% pull /system/framework/services.jar "%batDir%\work"
echo.
echo  正在将 apk 转成 smali
echo.
java -Xms1g -jar baksmali-2.2b4.jar d %batDir%\Brevent.apk -o %work%\apk
echo  正在将 services 转成 smali
echo.
java -Xms1g -jar baksmali-2.2b4.jar d %work%\services.jar -o %work%\services
echo  正在打补丁
echo.
python patch.py -a %work%\apk -s %work%\services
echo.
echo  正在输出打过补丁的 services
echo.
java -Xms1g -jar smali-2.2b4.jar a -o classes.dex %work%\services
jar -cvf services.jar classes.dex
md "%work%\new"
move services.jar %work%\new
del classes.dex
CLS
echo.
ECHO. ======================================================
echo.
echo  制作成功！生成的services.jar在\work\new\services.jar
echo.
echo  是否立即导入到手机？按任意键开始导入
echo.
echo  该操作须ROOT权限，如系统未ROOT请手动关闭此窗口！
echo.
ECHO. ======================================================
pause >nul
CLS
echo.
echo  正在导入services.jar到手机...
echo.
echo  当前操作会申请ROOT权限，请在手机端授权
echo.
%adb% push "%work%\new\services.jar" /sdcard/services.jar
%adb% shell su -c "mount -o rw,remount /system"
%adb% shell su -c "cp -rf /sdcard/services.jar /system/framework/services.jar"
%adb% shell rm /system/framework/oat/arm64/services.odex
echo.
goto Done

:odex
ECHO. ===============================================================
echo.
echo  请将手机的USB调试打开并连接电脑
echo.
echo  即将申请USB调试权限，请留意手机端的提示并授权，按任意键继续...
echo.
ECHO. ===============================================================
pause >nul
CLS
ECHO. =============================================================
echo.
echo  是否看见如下类似提示：
echo.
echo.
echo       List of devices attached
echo       * daemon not running. starting it now on port 5037 *
echo       * daemon started successfully *
echo       d6fb078b        device
echo.
echo.
echo  如果看到以上提示，说明手机与电脑连接正常，请按任意键继续...
echo.
echo  否则请关闭此窗口，检查驱动是否正确安装，手机是否正确连接
echo.
ECHO. =============================================================
echo.
%adb% devices
pause >nul
CLS
echo.
echo  正在提取system/framework到PC...
echo.
%adb% pull /system/framework "%batDir%\work"
echo.
ECHO  ========== 请选择你的Android版本 ==========
echo.
echo  1. Android 5.0 - Android 5.1
echo.
echo  2. Android 6.0 - Android 7.1
echo.
ECHO  ===========================================
set "select="
echo.
set /p select=请选择:
echo.
CLS
if /i '%select%'=='1' goto L
if /i '%select%'=='2' goto N

:L
java -Xms1g -jar oat2dex.jar boot %work%\framework\arm64\boot.oat
java -Xms1g -jar oat2dex.jar %work%\framework\arm64\services.odex %work%\framework\arm64\dex
java -Xms1g -jar baksmali-2.2b4.jar d %work%\framework\arm64\services.dex -o %work%\services
CLS
echo.
echo  正在将 apk 转成 smali
echo.
java -Xms1g -jar baksmali-2.2b4.jar d %batDir%\Brevent.apk -o %work%\apk
echo.
echo  正在打补丁
echo.
python patch.py -a %work%\apk -s %work%\services
echo.
echo  正在输出打过补丁的 services
echo.
java -Xms1g -jar smali-2.2b4.jar a -o classes.dex %work%\services
jar -cvf services.jar classes.dex
md "%work%\new"
move services.jar %work%\new
del classes.dex
echo.
ECHO. ======================================================
echo.
echo  制作成功！生成的services.jar在\work\new\services.jar
echo.
echo  是否立即导入到手机？按任意键开始导入
echo.
echo  该操作须ROOT权限，如系统未ROOT请手动关闭此窗口！
echo.
ECHO. ======================================================
pause >nul
CLS
echo.
echo  正在导入services.jar到手机...
echo.
echo  当前操作会申请ROOT权限，请在手机端授权
echo.
%adb% push "%work%\new\services.jar" /sdcard/services.jar
%adb% shell su -c "mount -o rw,remount /system"
%adb% shell su -c "cp -rf /sdcard/services.jar /system/framework/services.jar"
echo.
goto Done

:N
java -Xms1g -jar baksmali-2.2b4.jar x -d %work%\framework\arm64 %work%\framework\oat\arm64\services.odex -o %work%\services
CLS
echo.
echo  正在将 apk 转成 smali
echo.
java -Xms1g -jar baksmali-2.2b4.jar d %batDir%\Brevent.apk -o %work%\apk
echo.
echo  正在打补丁
echo.
python patch.py -a %work%\apk -s %work%\services
echo.
echo  正在输出打过补丁的 services
echo.
java -Xms1g -jar smali-2.2b4.jar a -o classes.dex %work%\services
jar -cvf services.jar classes.dex
md "%work%\new"
move services.jar %work%\new
del classes.dex
echo.
ECHO. ======================================================
echo.
echo  制作成功！生成的services.jar在\work\new\services.jar
echo.
echo  是否立即导入到手机？按任意键开始导入
echo.
echo  该操作须ROOT权限，如系统未ROOT请手动关闭此窗口！
echo.
ECHO. ======================================================
pause >nul
CLS
echo.
echo  正在导入services.jar到手机...
echo.
echo  当前操作会申请ROOT权限，请在手机端授权
echo.
%adb% push "%work%\new\services.jar" /sdcard/services.jar
%adb% shell su -c "mount -o rw,remount /system"
%adb% shell su -c "cp -rf /sdcard/services.jar /system/framework/services.jar"
%adb% shell rm /system/framework/oat/arm64/services.odex
echo.
goto Done

:Done
echo.
ECHO. ======================================================
echo.
echo  导入成功！是否立即安装黑域APP？
echo.
echo  按任意键开始安装，否则请手动关闭此窗口
echo.
ECHO. ======================================================
pause >nul
CLS
echo.
echo  正在安装黑域APP...
echo.
%adb% install %batDir%/Brevent.apk
echo.
ECHO. ======================================================
echo.
echo  安装成功！请手动重启手机使补丁生效
echo.
echo  按任意键关闭此窗口
echo.
ECHO. ======================================================
pause >nul