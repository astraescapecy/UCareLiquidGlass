# UCare (Liquid Glass)

Native **SwiftUI** iOS app for calm, body-focused routines: multi-select care goals, onboarding, a generated **Today** stack, **Progress** (Glow-Up Score, weekly check-in, photos, Discover), and **Profile** (account, reminders, export, subscription). **Glass-style** surfaces, spring motion with **Reduce Motion** fallbacks. Data is **on-device** for this MVP (UserDefaults, local files under Application Support)—no cloud backend in-repo.

**Visual theme:** glossy **true-black** base, **silver / ice** typography and strokes, and a **red → orange → yellow** gradient for primary actions (aligned with the product’s “liquid metal / iridescent edge” direction). Secondary chrome reuses legacy token names (`sage`, `terracotta`) in code but maps to that palette.

**Requirements:** Xcode with the **iOS 17** SDK, **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** on your `PATH`.

## Build and run

From the repository root:

```bash
xcodegen generate
open UCareLiquidGlass.xcodeproj
```

Select the **UCareLiquidGlass** scheme, then build and run on an **iPhone simulator** (or device) running **iOS 17+**. The scheme references `Configuration/UCareLiquidGlass.storekit` for local StoreKit testing.

## Onboarding flow (current)

1. **Splash** → **Welcome** (`GetStartedView`, single screen, no scroll) → **Auth** (sign up / sign in).  
2. **Username** (`UsernameSetupView`) — skipped if a **saved username** already passes local availability rules; otherwise pick a handle (green = available, red = taken/invalid).  
3. **Questionnaire** → **Paywall** / analysis / reveal as before → **Main** tabs.

**Auth MVP:** Email + password are **local only** (no server). **Forgot password** and **Sign in with Apple / Google** show explanatory alerts. For a reset in this build, use **Profile → Delete local account** (or log out) and sign up again.

**After subscribe:** A **congrats** screen runs on **new purchases** (and the first time after install until dismissed). **Restore purchases** skips that screen once the user has tapped **Begin your protocol** on congrats; the skip flag resets if the app detects the subscription has **lapsed** (restore with no active entitlement). Log out clears the flag with other defaults.

## What’s shipped (phases 1–6)

| Phase | Scope |
|-------|--------|
| **1** | Three-tab shell: **Today** · **Progress** · **Profile** (`MainTabView`, `RootView`). |
| **2** | **Today:** week strip, step cards, guided timer / tap-to-complete, confetti and completion UX. |
| **3** | **Progress:** Glow-Up Score + 7-day chart, weekly self-rating check-in, streaks/achievements, weekly photo thumbnails, **Discover** from bundled JSON. |
| **4** | **Profile:** identity, goals retake, reminder times, StoreKit manage/restore, step history, export JSON, help/FAQ, privacy actions, **Invite friends** (referral UX). |
| **5** | **Local notifications:** water interval, morning/evening/bedtime nudges, streak rescue (`UCareNotificationScheduler` + usage string in generated Info.plist). |
| **6** | **Apple Health (read-only):** dietary water + sleep analysis, optional blend into Glow-Up Score; HealthKit entitlement + `NSHealthShareUsageDescription`. |

**Referral screen:** Share copy + on-device promo code; **rewards / $10** are **marketing copy only** until a referral backend exists.

Source lives under `Sources/UCareLiquidGlass/` (features, app state, models, services). `project.yml` drives the Xcode project; entitlements live in `Configuration/`.

## Manual QA tips

- **Subscriptions:** use the StoreKit configuration file attached to the scheme, or attach your own in **Edit Scheme → Run → Options**.  
- **Notifications:** grant permission in the simulator, toggle nudges in **Profile**, then inspect pending requests via Xcode’s **Debug** workflows or the simulator’s notification surface.  
- **Health (Phase 6):** in the **Health** app, add sample **Water** and **Sleep** data; in **Profile** enable “Blend water & sleep into Glow-Up”; open **Progress** to refresh the cached Health snapshot.  
- **Username:** try reserved or demo-taken handles (e.g. `test`, `admin`) to see red state; use a fresh handle for green.

## Repository layout (short)

- `Sources/UCareLiquidGlass/` — SwiftUI app, `AppState`, onboarding, tabs.  
- `Resources/` — assets and `discover_feed.json`.  
- `Configuration/` — StoreKit config, HealthKit entitlements.  
- `project.yml` — XcodeGen project definition (bundle id `com.ucare.liquidglass`).

Commit history on `main` matches these phases; see [commits on `main`](https://github.com/astraescapecy/UCareLiquidGlass/commits/main) for the exact messages.
