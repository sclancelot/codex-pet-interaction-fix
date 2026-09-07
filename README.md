# Codex Pet Interaction Fix

一个 Codex skill，用于排查和临时处理 Windows 桌面宠物鼠标穿透、无法拖动和悬停失效。

通过本地 CDP 读取宠物可见区域，每 200 毫秒更新 Windows 窗口区域；不修改客户端安装包或宠物素材，不注册开机启动。

## 安装

把仓库中的 `codex-pet-interaction-fix` 文件夹复制到 `$CODEX_HOME/skills/`（未设置时为 `~/.codex/skills/`），重新打开 Codex 后调用：

```text
$codex-pet-interaction-fix 检查宠物鼠标穿透，并验证拖动和悬停
```

也可以让 Codex 的 skill-installer 从本仓库安装 `codex-pet-interaction-fix` 路径。

## 环境与直接运行

Windows、Node.js 22+、Windows PowerShell 5.1+。Codex 必须已打开宠物，并在本机 9341 端口启用调试。脚本不自动重启 Codex，也不自动配置此端口。

在 skill 文件夹中运行：

```powershell
node scripts/bridge.cjs --check
powershell -NoProfile -File scripts/start.ps1
powershell -NoProfile -File scripts/stop.ps1
```

仅当基础处理无效、诊断符合窗口命中错位时，停止旧实例后可测试 `start.ps1 -ResetLayer`。运行状态和错误日志在 `scripts/`，已排除出 Git。

## 验证范围

原始手工修复在 Windows Store Codex 26.901.6511.0 上由用户确认恢复交互，随后启用了位置跟踪。该成功过程包含多个操作；**没有证明单独运行区域跟踪就能修复所有同类故障**。打包后的启动/停止流程和原生辅助程序另做本地验证，不能替代每台机器上的拖动、悬停和空白区域穿透测试。

这是当前会话的实验性兼容方案。客户端关闭或宠物页面销毁后退出。区域同时影响绘制，未来版本、快速拖动、混合 DPI 和新控件均需复测。完整边界见 [诊断说明](codex-pet-interaction-fix/references/diagnosis.md)。
