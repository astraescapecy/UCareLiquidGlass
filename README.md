# UCare (Liquid Glass)

Native **SwiftUI** iOS app for calm, body-focused routines: multi-select care goals, onboarding, a generated **Today** stack, **Progress** (Glow-Up Score, weekly check-in, photos, Discover), and **Profile** (account, reminders, export, subscription). Liquid-glass visuals, spring motion with **Reduce Motion** fallbacks. Data is **on-device** for this MVP (UserDefaults, local files under Application Support)—no cloud backend in-repo.

**Requirements:** Xcode with the **iOS 17** SDK, **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** on your `PATH`.

## Build and run

From the repository root:

```bash
xcodegen generate
open UCareLiquidGlass.xcodeproj
```

Select the **UCareLiquidGlass** scheme, then build and run on an **iPhone simulator** (or device) running **iOS 17+**. The scheme references `Configuration/UCareLiquidGlass.storekit` for local StoreKit testing.

## What’s shipped (phases 1–6)

| Phase | Scope |
|-------|--------|
| **1** | Three-tab shell: **Today** · **Progress** · **Profile** (`MainTabView`, `RootView`). |
| **2** | **Today:** week strip, step cards, guided timer / tap-to-complete, confetti and completion UX. |
| **3** | **Progress:** Glow-Up Score + 7-day chart, weekly self-rating check-in, streaks/achievements, weekly photo thumbnails, **Discover** from bundled JSON. |
| **4** | **Profile:** identity, goals retake, reminder times, StoreKit manage/restore, step history, export JSON, help/FAQ, privacy actions. |
| **5** | **Local notifications:** water interval, morning/evening/bedtime nudges, streak rescue (`UCareNotificationScheduler` + usage string in generated Info.plist). |
| **6** | **Apple Health (read-only):** dietary water + sleep analysis, optional blend into Glow-Up Score; HealthKit entitlement + `NSHealthShareUsageDescription`. |

Source lives under `Sources/UCareLiquidGlass/` (features, app state, models, services). `project.yml` drives the Xcode project; entitlements live in `Configuration/`.

## Manual QA tips

- **Subscriptions:** use the StoreKit configuration file attached to the scheme, or attach your own in **Edit Scheme → Run → Options**.  
- **Notifications:** grant permission in the simulator, toggle nudges in **Profile**, then inspect pending requests via Xcode’s **Debug** workflows or the simulator’s notification surface.  
- **Health (Phase 6):** in the **Health** app, add sample **Water** and **Sleep** data; in **Profile** enable “Blend water & sleep into Glow-Up”; open **Progress** to refresh the cached Health snapshot.

## Repository layout (short)

- `Sources/UCareLiquidGlass/` — SwiftUI app, `AppState`, onboarding, tabs.  
- `Resources/` — assets and `discover_feed.json`.  
- `Configuration/` — StoreKit config, HealthKit entitlements.  
- `project.yml` — XcodeGen project definition (bundle id `com.ucare.liquidglass`).

Commit history on `main` matches these phases; see [commits on `main`](https://github.com/astraescapecy/UCareLiquidGlass/commits/main) for the exact messages.
