# Recommended tweaks to add next

A gap analysis of YouMod against **uYouEnhanced**, **YTLite / YTPlus** (last free version 5.2b4), **YTLitePlus** and **uYouPlus**, so we can prioritise what to build.

Sources checked: [uYouEnhanced README](https://github.com/arichornlover/uYouEnhanced), [YTLite README](https://github.com/dayanch96/YTLite), [YTLitePlus README](https://github.com/YTLitePlus/YTLitePlus), plus the code in this repo. Both upstream READMEs now recommend YouMod as the open-source alternative, and both list the same gaps — the sections below are ordered by how much they close those gaps.

Legend: 🟢 small (hours), 🟡 medium (a day or two), 🔴 large (a proper project).

---

## 1. The gaps uYouEnhanced/YTLitePlus explicitly list against YouMod

uYouEnhanced's own "Lightweight Alternative - YouMod" section names these cons. Fixing them is the highest-leverage work we can do.

| # | Feature | Effort | Notes |
|---|---------|:------:|-------|
| 1.1 | **App version spoofing** (`YTAppVersionSpoofer`) | 🟡 | Bypasses the "Please update / Update required" screen and lets users fake older versions to keep removed features alive. Adapt from [arichornlover/YTAppVersionSpoofer](https://github.com/arichornlover). YouMod already does bundle-ID spoofing in `Sideloading.x`, so the plumbing exists. |
| 1.2 | **"Fix Google Sign-In" toggle** | 🟡 | uYouEnhanced ships a TrollStore-specific sign-in fix. Our `SSOConfiguration` / `GULKeychainStorage` / `NSBundle` hooks in `Sideloading.x` are the same area — add the toggle next to them. |
| 1.3 | **"Fix Casting" toggle** | 🟡 | A/B flags that broke Chromecast casting. Needs a couple of `YTColdConfig`/`YTHotConfig` overrides or an `YTABConfig` preset (YTABConfig is already in `ipa.yml`). |
| 1.4 | **Client spoofing (innertube client)** | 🔴 | The fix for "Sign in to confirm you're not a bot" / playback errors. PoomSmart's [YouTubeClientSpoofer](https://github.com/PoomSmart/YouTubeClientSpoofer) is the reference implementation. |
| 1.5 | **Built-in SponsorBlock** | 🟢 (done) | iSponsorBlock was added to `ipa.yml` in `034016c`. Nothing to do unless we later want it native. |
| 1.6 | **LowContrastMode** | 🟡 | Darken text site-wide. Either integrate [YTLowContrastMode](https://github.com/arichornlover/YTLowContrastMode) or port the colour hooks — it's mostly `YTColor`/label hooks, the same pattern as `Apperence.x`. |
| 1.7 | **NotificationsTab** | 🔴 | Rebuilds the notifications tab YouTube removed in 2020. Big and fragile (Inertube endpoints); worth doing only if we want a headline differentiator. |

---

## 2. Player features worth porting

| # | Feature | Effort | Notes |
|---|---------|:------:|-------|
| 2.1 | **Copy link at current timestamp** (`YouTimeStamp`) | 🟢 | `Download.x` already has `YouModCopyVideoInfo` and the player/time accessors — append `&t=<seconds>s` and add a menu row. |
| 2.2 | **Remember last caption choice** (`YouRememberCaption`) | 🟢 | We have the opposite toggle today (`DisablesCaptions` auto-turns captions off). Persist `setActiveCaptionTrack:` instead. |
| 2.3 | **Default quality on load** | 🟡 | YTLite's "default quality" option. Start every video at a chosen height (e.g. always 1080p) instead of YT's adaptive guess. Hook where `setUserSelectableFormats:`/quality selection happens — `OldVideoQuality` group in `Player.x` is the closest existing code. |
| 2.4 | **Preferred audio track / language** | 🟡 | YTLite has "preferred audio track". We only expose audio *format* at download time (`Download.x`), never for playback. |
| 2.5 | **Mute button + overlay buttons** | 🟢 (done) | YouMute / YouQuality / YouSpeed are already wired through `ipa.yml`. Optional native equivalents later. |
| 2.6 | **Miniplayer for all videos** (`YTMiniplayerEnabler`) | 🟡 | We have `ForceMiniPlayer` (disable miniplayer) but not "enable it for videos that don't allow it". Small hook on the miniplayer renderer — `ForceMiniPlayer` group in `Player.x` is the template. |
| 2.7 | **Hold-to-seek speed** (`YTHoldForSpeed`) | 🟢 (done) | Already an `ipa.yml` toggle. |

---

## 3. Feed / navigation features

| # | Feature | Effort | Notes |
|---|---------|:------:|-------|
| 3.1 | **Tab bar reordering** | 🟡 | **The README already claims this** ("Tab bar (reorder, add/remove buttons)") but `Tabbar.x` only *hides* tabs and sets the startup tab. Implement it by reordering `itemsArray` in `YTPivotBarView setRenderer:` (the hide logic is already there), or drop the claim from the README. |
| 3.2 | **Open Shorts in the regular player** | 🟡 | There is a commented-out `shortsToRegular` sketch in `Player.x` — finish it (vnd.youtube deep link or redirect the reel endpoint) as the "no more Shorts UI" option. |
| 3.3 | **Shorts-only mode** | 🔴 | YTLite has it; the inverse of 3.2 — home feed shows Shorts shelves only. Reuses the `Shorts` filter group in `Feed.x`. |
| 3.4 | **Hide Shorts from search results** | 🟡 | We hide the shelf, the tab and many buttons, but Shorts still dominate search. Filter `YTISearchSectionRenderer` contents the same way `Ads.x` filters ad renderers. |
| 3.5 | **Hide Mix / "Trending" / music shelves** | 🟢 | Extend `Feed.x`'s `filteredArray` — it already recognises shelf renderers; add pivot identifiers for mix/trending shelves as toggles. |
| 3.6 | **Hide the comments panel** | 🟢 | We can hide the Shorts comment *button* but not the watch-page comments section. One `_ASDisplayView` identifier check in `Sideloading.x`. |

---

## 4. The download manager (biggest differentiator left)

YTLite's headline feature is a real download manager. YouMod has a solid downloader (range requests, 8-way chunking, AVFoundation merge, Photos export) but:

- **No queue** — starting a second download just shows *"Already downloading"*.
- **No library / resume** — files land in `Documents/YouMod Downloads` but there's no in-app list, no resume, no cancel, no delete, no offline playback.
- **No progress history** — only a transient alert.

Suggested steps, smallest first:

1. 🟡 **Queue** — turn `YouModDownloadCoordinator` from a singleton-active model into a serial queue of jobs. Mostly bookkeeping; the range downloader already handles a whole file.
2. 🔴 **Library screen** — a `YTSettingsPickerViewController`-style section (we already build settings screens from scratch in `Settings.x`) listing `Documents/YouMod Downloads`, with share / delete / play (`AVPlayer`).
3. 🔴 **Resume** — persist downloaded byte ranges per job next to the file (`.youmod.part` + offsets). The chunk model in `YouModRangeDownloader` already thinks in ranges, so this is a natural fit.

---

## 5. Polish / quality-of-life

| # | Item | Effort | Notes |
|---|------|:------:|-------|
| 5.1 | **"Restart required" hint** | 🟢 | Groups gated in `%ctor` (`OldVideoQuality`, `Gestures`, `OLEDTheme`, `PaidPromoOverlay`, …) only apply after an app restart. YTLite shows a prompt; we should at least say so in the setting description. |
| 5.2 | **Localise the download UI** | 🟡 | Every string in `Download.x` ("Download video", "Save to Photos", …) is hardcoded English while settings are translated into 35 languages. |
| 5.3 | **Single settings document for defaults** | 🟢 (done) | `YouModRegisterDefaults()` — see `Files/Settings.x`. |
| 5.4 | **Reset import/export to also cover new keys** | 🟢 (done) | Import now validates before wiping (see `Files/YouModPerferences.x`). |
| 5.5 | **CI: pin third-party clones** | 🟡 | `ipa.yml` clones ~20 repos at `HEAD` plus `pipx install …/archive/main.zip`. Pinning to SHAs makes releases reproducible and avoids a supply-chain surprise. |
| 5.6 | **Auto-clear cache default** | 🟢 | `AutoClearCache` defaults to `YES`, so every launch throws away YouTube's whole cache (slower cold starts). Consider defaulting to `NO` and letting users opt in. |

---

## 6. Suggested order of attack

1. **5.1 + 2.1 + 2.2 + 3.6** — quick, visible wins, all green.
2. **3.1 (tab reorder)** — the README promises it.
3. **1.1 version spoofing + 1.2 sign-in fix** — directly closes the two cons listed against us upstream.
4. **4.1 download queue** — sets up the library screen.
5. **1.4 client spoofing** — the hardest, but removes the biggest "uYouEnhanced is still needed" complaint.
