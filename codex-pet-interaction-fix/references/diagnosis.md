# Evidence and limits

Observed on Codex Windows Store build 26.901.6511.0: the pet rendered at the bottom right while an OS `WindowFromPoint` grid selected the overlay only in an upper-left rectangle. The overlay was visible and its extended style could lack `WS_EX_TRANSPARENT` despite the failure. The user had already tried 100% scaling without improvement.

The successful session included a temporary layered-style clear/restore, a fresh renderer-region submission, and a native `SetWindowRgn` at the visible pet coordinates. The user then confirmed that interaction worked. A 200 ms DOM-to-native tracker followed subsequent position changes. This is evidence for the combined workaround, not proof that the tracker alone or any isolated step repairs every affected build.

The packaged optional `-ResetLayer` performs only the bounded layered-style experiment and region tracking; it does not reach into private React fibers or send undocumented app RPCs. That exact packaged sequence has not yet received the same end-to-end user confirmation as the original session. Do not silently escalate to arbitrary renderer internals if it fails.

`SetWindowRgn` clips drawing as well as input. The tracker includes visible pet/activity/control/menu rectangles with padding, but future DOM changes, shadows, new tooltips, multiple monitors and mixed DPI may require further validation. It polls and can lag animation or a fast drag by one interval. It matches a unique visible tool window in the identified Codex process by viewport dimensions; ambiguity aborts application instead of guessing.

For native verification, compute screen coordinates from the live renderer/window geometry in a per-monitor DPI-aware context. Probe the pet center and a small grid over the visible body; compare each `WindowFromPoint` root with the current pet window. Test while actually hovering: the application's intentional click-through state while the cursor is elsewhere can make an off-cursor grid misleading. Check that blank areas remain click-through. Never reuse handles or hard-coded coordinates from the original machine.

Public reports of similar symptoms (user reports, not an official root-cause confirmation):
- https://github.com/openai/codex/issues/42661
- https://github.com/openai/codex/issues/41519
