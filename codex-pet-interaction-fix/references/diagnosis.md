# Evidence and limits

## One-shot reset (default since 2026-09-10)

On Windows Store Codex 26.901.6511.0, reset-pet-once.ps1 temporarily cleared only WS_EX_LAYERED, refreshed the frame, waited three seconds, then restored that bit and exited. The same HWND read 0x2800A8 before and after. No repair helper remained running. In response to a request to test hover, right-click, two consecutive drags and clicks outside the pet, the user confirmed that interaction and surrounding clicks worked. The published script is identical to that tested script.

This verifies recovery in that session only. Restart persistence, other versions and display configurations remain unverified. It neither proves a universal root cause nor guarantees a permanent fix. The script identifies a unique visible layered/topmost tool window in a unique Store Codex desktop process; these style predicates do not prove pet identity. Establish the visible tool is the pet before applying, and do not run against an active voice orb.

Related first-hand reports: https://github.com/openai/codex/issues/43200 . Leaving WS_EX_LAYERED removed can cause surrounding transparent areas to intercept input; the one-shot test instead restores it. Do not forcibly terminate during the reset. If restoration is interrupted, recreate the pet window.

## Historical combined repair and resident tracker

Observed on Codex Windows Store build 26.901.6511.0: the pet rendered at the bottom right while an OS `WindowFromPoint` grid selected the overlay only in an upper-left rectangle. The overlay was visible and its extended style could lack `WS_EX_TRANSPARENT` despite the failure. The user had already tried 100% scaling without improvement.

The successful session included a temporary layered-style clear/restore, a fresh renderer-region submission, and a native `SetWindowRgn` at the visible pet coordinates. The user then confirmed that interaction worked. A 200 ms DOM-to-native tracker followed subsequent position changes. This is evidence for the combined workaround, not proof that the tracker alone or any isolated step repairs every affected build.

The packaged optional `-ResetLayer` performs only the bounded layered-style experiment and region tracking; it does not reach into private React fibers or send undocumented app RPCs. That exact packaged sequence has not yet received the same end-to-end user confirmation as the original session. Do not silently escalate to arbitrary renderer internals if it fails.

`SetWindowRgn` clips drawing as well as input. The tracker includes visible pet/activity/control/menu rectangles with padding, but future DOM changes, shadows, new tooltips, multiple monitors and mixed DPI may require further validation. It polls and can lag animation or a fast drag by one interval. It matches a unique visible tool window in the identified Codex process by viewport dimensions; ambiguity aborts application instead of guessing.

For native verification, compute screen coordinates from the live renderer/window geometry in a per-monitor DPI-aware context. Probe the pet center and a small grid over the visible body; compare each `WindowFromPoint` root with the current pet window. Test while actually hovering: the application's intentional click-through state while the cursor is elsewhere can make an off-cursor grid misleading. Check that blank areas remain click-through. Never reuse handles or hard-coded coordinates from the original machine.

Public reports of similar symptoms (user reports, not an official root-cause confirmation):
- https://github.com/openai/codex/issues/42661
- https://github.com/openai/codex/issues/41519
