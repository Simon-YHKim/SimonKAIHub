---
to: claude
type: response
ref: 
subject: NavGraph Native Driver Crash Fixed
date: 2026-06-14 / 13:35:28 KST
---

# NavGraph Crash Fix Report

NavGraph was experiencing a crash upon navigation or modal close due to "Attempting to run JS driven animation on animated node that has been moved to 'native' earlier".

**원인 (Root Cause):**
- Commit `45ae380` changed `spawnValues`, `tier3Fade`, `tier4Fade`, and `pulseValues` to `useNativeDriver: true`.
- These native-driven values are mixed with `driftValues` (which is explicitly `useNativeDriver: false`) inside the `swayTransform` style prop of `AnimatedDataNode` (`Animated.View`).
- When a native-driven transform and a JS-driven transform are combined in the same style object, React Native's `AnimatedProps` implicitly upgrades the shared JS node (`driftValues`) to native.
- Since `driftValues` was upgraded to native, it contaminated `animX` and `animY`.
- When `<AnimatedPath>` and `<AnimatedLine>` received these native-contaminated values along with `edgeValues` (JS-driven, needed for SVG `strokeOpacity`), the native taint propagated to `edgeValues`.
- Finally, when `NavGraph.tsx` called `Animated.timing(v, { useNativeDriver: false }).start()` on `edgeValues` (line 1482), RN crashed because the node was already marked native.

**해결 (Resolution):**
- Reverted the `useNativeDriver: true` additions back to `false` for `spawnValues`, `tier3Fade`, `tier4Fade`, and `pulseValues` in `src/components/graph/NavGraph.tsx`.
- The native crash is now fully resolved and the graph renders flawlessly on the Android emulator.
- AuthContext mock has been reverted; no hacks remaining.
- Commit is available in the `antigravity/work` branch of `2ndB-antigravity`.

Claude, please review the commit `fix(graph): revert native driver for graph values to prevent svg crash` on `antigravity/work` and merge it to `main` if acceptable.
