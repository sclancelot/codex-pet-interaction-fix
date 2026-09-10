# Codex Pet Interaction Fix

临时修复 Windows Codex 桌面宠物鼠标穿透、无法拖动和悬停失效。

**默认方案已改为一次性重置：临时清除分层样式，刷新窗口，三秒后恢复，程序随即退出。** 不需要 Node.js、调试端口或常驻脚本，不修改安装包、宠物素材和启动配置。

## 安装和运行

把仓库中的 `codex-pet-interaction-fix` 文件夹复制到 `$CODEX_HOME/skills/`（未设置时为 `~/.codex/skills/`），重新打开 Codex 后调用：

```text
$codex-pet-interaction-fix 修复宠物鼠标穿透，使用一次性重置
```

也可让 skill-installer 从本仓库安装 `codex-pet-interaction-fix` 路径。

需要 Windows、64 位 Windows PowerShell 5.1+，先在 Codex 中显示宠物。在 skill 文件夹中运行：

```powershell
# 只检查目标
powershell -NoProfile -File scripts/reset-pet-once.ps1 -InspectOnly
# 重置并退出，无需另行停止
powershell -NoProfile -File scripts/reset-pet-once.ps1
```

当前脚本识别 Windows Store 安装路径下的 ChatGPT.exe，要求主进程及可见分层置顶工具窗口均唯一，不能唯一识别时拒绝修改。运行前确认该窗口是宠物，未打开语音球等其他悬浮工具。其他安装路径和进程名尚不支持。

## 验证与限制

2026-09-10，在 Windows Store Codex **26.901.6511.0** 上执行一次性重置，同一窗口的原样式和结束样式均为 `0x2800A8`；工具正常退出，复查无残留修复进程。用户对悬停、右键、连续拖动两次和周边空白点击的验收问题确认：**“交互恢复，旁边也能正常点击”。**

这证明本次恢复有效，**不代表永久修复，也未验证重启后仍有效**。重建宠物窗口或重启后可能复发，届时可再次运行。不要为此注册常驻程序或开机任务。

脚本保留 WS_EX_TRANSPARENT，在 finally 中恢复 WS_EX_LAYERED，不持续取消透明区域命中规则。三秒测试期间可能短暂影响周边点击；若强制终止导致未恢复，关闭再打开宠物以重建窗口。每次执行后均需验证实际交互和空白区域点击。

## 旧方案

start.ps1、stop.ps1、bridge.cjs、native-region.ps1 保留作历史备选：需要 Node.js 22+ 和本机 CDP 9341，每 200 毫秒跟踪窗口区域，运行期间有常驻进程。**不再作为默认方案，也不符合“不运行常驻脚本”的要求。** 先停止旧实例，再测试一次性重置。

详情见[诊断说明](codex-pet-interaction-fix/references/diagnosis.md)和[历史方案](codex-pet-interaction-fix/references/legacy-tracker.md)。
