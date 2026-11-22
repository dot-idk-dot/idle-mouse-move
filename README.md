# idle-mouse-move
Windows 下轻量防休眠鼠标微动脚本。调用系统 API 阻止睡眠与熄屏，配合鼠标左右往复微移兜底。


![鼠标移动gif](assets/mouse_move.gif "鼠标移动演示")


## 🚀 运行方式
### 方法一：双击批处理
- 正式版：双击 `run_mouse_move.bat`
- 调试版：双击 `run_test.bat`（生成 `mouse_log.txt`）


### 方法二：命令行手动运行
PowerShell：


```powershell
# 正式版
powershell -NoProfile -ExecutionPolicy Bypass -File mouse_move.ps1


# 调试版
powershell -NoProfile -ExecutionPolicy Bypass -File test_power.ps1
```


CMD：


```cmd
:: 运行正式主脚本
cd 脚本所在文件夹
run_mouse_move.bat


:: 运行调试脚本
run_test.bat
```


## ⚙️ 参数说明
`mouse_move.ps1`（正式版）：
```powershell
$moveAmount = 50        # 单次移动像素距离
$leftMoveTime = 5000    # 左移完成后等待毫秒数
$rightMoveTime = 5000   # 返回完成后等待毫秒数
```


`test_power.ps1`（调试版）：
```powershell
$moveAmount = 50        # 单次移动像素距离
$leftTime = 5000        # 左移完成后等待毫秒数
$rightTime = 5000       # 返回完成后等待毫秒数
```

## 🔧 常见问题
### Q1：鼠标完全不移动？
A：逐项排查：


1. 安全软件拦截了脚本调用 Windows 鼠标 API；
2. 使用调试脚本 `run_test.bat`，查看 `mouse_log.txt` 判断脚本是否正常执行。

### Q2：开了脚本屏幕还是灭 / 事件查看器出现 Kernel-Power 42？
A：脚本调用 `SetThreadExecutionState` 阻止系统睡眠和显示器关闭，但以下情况可能拦不住：

- **`SetThreadExecutionState` 未生效**：必须在主线程调用，且标志位齐全。用 `powercfg /requests` 确认脚本进程出现在 `SYSTEM` / `DISPLAY` 段。
- **鼠标微动重置不了空闲计时器**：`SetCursorPos` 只改坐标不产生真实输入事件，系统不认。API 层没挂上时鼠标层也救不了。
- **无人参与睡眠超时**：Win10/11 默认有 2 分钟 `System unattended sleep timeout`，即使设了“从不”也会到点睡。用 `powercfg -attributes SUB_SLEEP 7bc4a2f9-d8fc-4469-b07b-33eb785aaca0 -ATTRIB_HIDE` 显示该选项，然后设为 0。
- **Modern Standby (S0) 固件层硬睡**：`powercfg /a` 看到 `Standby (S0 Low Power Idle)` 的机器，固件可在 API 请求仍在时自行进入低功耗，脚本拦不住。
- **组策略 / 厂商管家 / 计划任务强制睡眠**：脚本管不了，需自行调整策略或卸载相关软件。


### Q3：找不到 mouse_log.txt？
A：日志文件**只有调试脚本 `test_power.ps1` 才会输出**，正式主脚本不会生成日志。


## 📝 技术细节
1. 光标控制：`user32.dll` 的 `SetCursorPos`、`GetCursorPos`
2. 防休眠实现：`kernel32.dll` 的 `SetThreadExecutionState`
   - 标志：`ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED`
   - 作用：阻止系统进入睡眠，阻止显示器自动关闭；进程结束自动失效。


## ⚖️ 免责声明
本脚本仅供学习测试使用。使用本脚本带来的一切问题，包括但不限于系统异常、鼠标行为异常等，由使用者自行承担风险。


**不能干的事（划重点）：**
- ❌ 不能绕过家长控制 / 定时关机软件
- ❌ 不能破解锁屏密码
- ❌ 不能阻止别人手动关机
- ❌ 不能让已经关机的电脑保持运行


> 请勿用于游戏挂机或违规用途，部分游戏会检测模拟输入行为。


## 📄 作者与 AI 生成声明
- 初始代码草稿由 **GLM‑4.7‑Flash** 和 **Kilo** 生成
- README.md、描述、.gitignore 和一部分代码审查由 **豆包** 和 **元宝** 处理
- 另一部分代码审查由 **dot-idk-dot** 和 **LLLyyy-star** 测试
- 版本：1.1.0
- 最后一次更改：2026.11.22