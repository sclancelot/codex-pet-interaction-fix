---
name: codex-pet-interaction-fix
description: Diagnose and temporarily repair Windows Codex desktop pets that are visible but click-through, cannot be dragged, or ignore hover because their native input region is misaligned. Use for pet window interaction failures, not sprite creation or animation redesign.
---

# Codex pet interaction fix

This is a Windows-only, session-scoped workaround. It tracks the pet renderer's visible regions and applies their union as a native window region. It does not patch the installed application or pet assets.

## Diagnose first

- Establish whether hover, right-click and dragging fail. A valid sprite does not establish that native mouse hit testing works.
- Read `references/diagnosis.md` for the observed failure, interpretation limits and verification requirements.
- Require Windows, Node.js 22+ and Windows PowerShell 5.1+. Resolve the scripts relative to this SKILL.md; do not use machine-specific paths.
- Run `node scripts/bridge.cjs --check`. It is read-only and requires one running Codex desktop process and one pet page on loopback CDP port 9341.
- If CDP is unavailable, do not restart the user's active Codex task. Explain the prerequisite: a deliberate subsequent Codex launch with `--remote-debugging-address=127.0.0.1 --remote-debugging-port=9341`. Do not expose this port on the network or persist a new launch configuration implicitly.
- Never infer an empty input region from `GetWindowRgn == 0`, or zero opacity from a failed `GetLayeredWindowAttributes`. A logical/physical 2x difference at 200% scaling is normal, not proof of a DPI defect.

## Apply within the requested repair scope

1. Stop any other copy of this workaround before starting this one; concurrent window-region writers invalidate diagnosis.
2. Start `powershell -NoProfile -File scripts/start.ps1`. Check `scripts/status.json` for a fresh `lastApplied` and `scripts/helper-error.log` for failures.
3. Verify actual mouse interaction. A successful `SetWindowRgn` call or fresh heartbeat is not proof of a working pet.
4. If the region tracker alone fails and native diagnosis still shows a misplaced layered-window hit area, stop it and run `powershell -NoProfile -File scripts/start.ps1 -ResetLayer`. This optional step briefly clears and restores the existing layered-window style before applying the region. Use it as a bounded compatibility experiment, not a default Windows setting change. It may repaint the window; stop if the pet disappears or blocks unrelated screen areas.
5. Test hover, right-click, dragging twice to different locations, activity/voice controls without starting a voice call, and click-through outside the pet. Include resize/display changes only when relevant. Ask the user for physical interaction confirmation if native input testing is unavailable; do not substitute synthetic DOM events.

## Stop and report

Run `powershell -NoProfile -File scripts/stop.ps1`. Wait for the helper to exit. On normal exit it restores the captured native region, or removes its region when no explicit region was available. If a helper was force-killed, close and reopen the pet to restore the client's original window state.

Report the observed result and separate native checks, user-confirmed behavior, and untested scenarios. This repair expires when the pet page or Codex closes. Do not add auto-start, scheduled tasks, binary patches, or permanent configuration changes unless separately requested.
