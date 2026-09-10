---
name: codex-pet-interaction-fix
description: Diagnose and temporarily repair visible Windows Codex desktop pets that ignore hover, clicks or dragging. Defaults to a one-shot window reset that restores the layered state and exits without a resident helper.
---

# Codex pet interaction fix

Default to the one-shot reset. It briefly clears WS_EX_LAYERED, refreshes the window, waits three seconds, restores that bit while preserving other current style bits, and exits. No Node.js, CDP, installation changes or startup configuration are needed.

## Diagnose and apply

1. Establish that the pet is visible but not interactive. Read [diagnosis.md](references/diagnosis.md) for evidence and limits. Do not assume a DPI or sprite problem.
2. Require Windows and 64-bit Windows PowerShell 5.1+. Resolve scripts relative to this skill. Currently supported: Windows Store Codex with desktop process ChatGPT.exe.
3. Confirm the visible floating tool is the pet, not a voice orb or other overlay. Stop any old region tracker before this test. Run `powershell -NoProfile -File scripts/reset-pet-once.ps1 -InspectOnly`. Ambiguous identification aborts; do not substitute remembered HWNDs or guessed coordinates.
4. Run `powershell -NoProfile -File scripts/reset-pet-once.ps1`. Let it finish so its finally block restores the layered state. No separate stop command is needed. If forcibly interrupted, close and reopen the pet to recreate the window.
5. Verify hover, right-click, two successive drags, and clicks outside the pet after the helper exits. Obtain physical user confirmation when actual native interaction cannot be tested. A restored style or exit code alone does not establish success.

## Report the boundary

The one-shot reset was user-confirmed on Windows Store Codex 26.901.6511.0 on 2026-09-10 with no repair process left running. Cross-restart persistence is unverified. This is temporary recovery, not a permanent product fix. Re-run only when symptoms recur; do not add polling, auto-start, scheduled tasks or binary patches to this workflow.

Never infer an empty input region from GetWindowRgn == 0, or zero opacity from failed GetLayeredWindowAttributes. Probe while actually hovering: intentional click-through with the cursor elsewhere can make off-cursor grids misleading.

## Legacy tracker: explicit fallback only

The old start.ps1 / stop.ps1 / bridge.cjs / native-region.ps1 files remain for historical use. They run continuously and require Node.js 22+ and loopback CDP 9341. Do not launch them automatically after a failed reset, especially when the user rejects resident helpers. Read [legacy-tracker.md](references/legacy-tracker.md) only when that mode is explicitly requested. Paths in that historical document are relative to the skill root.
