# Recommended tweaks to add next

Two routes, mirroring what the competition does:

1. **Bundle** standalone open-source tweaks into the IPA build (`ipa.yml`) — this is the uYouPlus route, and it's cheap: each one is a clone step + a build + a `mv *.deb`, behind its own boolean input.
2. **Port** features natively into YouMod — keeps the "single lightweight tweak" pitch, but it's real work.

Sources checked: [uYouPlus](https://uyouplus.com/) (archived README), [uYouEnhanced README](https://github.com/arichornlover/uYouEnhanced), [YTLite README](https://github.com/dayanch96/YTLite), [YTLitePlus README](https://github.com/YTLitePlus/YTLitePlus), plus this repo's code. Both upstream READMEs now recommend YouMod as the open-source alternative, and both name the same gaps.

Legend: 🟢 small (hours), 🟡 medium (a day or two), 🔴 large (a proper project). ✅ = already ours.

---

## 1. Bundled tweaks — what uYouPlus ships that we don't

**Already bundled in `ipa.yml`:** YouPiP ✅, YTUHD ✅, iSponsorBlock ✅, Return-YouTube-Dislikes ✅, YouGroupSettings ✅, YTVideoOverlay ✅, YTABConfig ✅, YouQuality ✅, YouSpeed ✅, DontEatMyContent ✅, YouMute ✅, YouLoop ✅, YouSlider ✅, YTHoldForSpeed ✅, YouChooseQuality ✅, YouShare ✅, YTweaks ✅, Gonerino ✅, YouGetCaption ✅, youtube-native-share ✅, VolumeBoostYT ✅, OpenYouTubeSafariExtension ✅.

**Worth adding** (every repo below was verified to exist on the day this was written):

| Tweak | Source | What it does | Verdict |
|-------|--------|--------------|---------|
| **YTMiniplayerEnabler** | [level3tjg/YTMiniplayerEnabler](https://github.com/level3tjg/YTMiniplayerEnabler) | Enables the miniplayer for videos that don't allow it | 🟢 **Real gap** — we only ship the *disable* direction (`ForceMiniPlayer`) |
| **YouTimeStamp** | [arichornlover/YouTimeStamp](https://github.com/arichornlover/YouTimeStamp) | "Copy timestamp" button in the player | 🟢 **Natural fit** — it's built *for* YTVideoOverlay, which we already bundle |
| **YTReExplore** | [PoomSmart/YTReExplore](https://github.com/PoomSmart/YTReExplore) | Removes the Shorts tab and puts the Explore tab back | 🟢 Great companion to our `HideShortsTab` (which currently just leaves a hole) |
| **BigYTMiniPlayer** | [Galactic-Dev/BigYTMiniPlayer](https://github.com/Galactic-Dev/BigYTMiniPlayer) | Makes the miniplayer bigger/easier to hit | 🟢 Pairs with the above two |
| **YTNoHoverCards** | [level3tjg/YTNoHoverCards](https://github.com/level3tjg/YTNoHoverCards) | Kills the end-of-video overlay | 🟡 Partially ours already (`HideSuggestedVideo`, `HideEndScreenCards`) — add it only if the native checks miss overlay cases |
| **YouTube-X** | [PoomSmart/YouTube-X](https://github.com/PoomSmart/YouTube-X) | "Lightweight YouTube improvement tweak" | 🟡 Overlaps `Ads.x` heavily — bundle as an *opt-in* input, not default |
| **NoYTPremium** | [PoomSmart/NoYTPremium](https://github.com/PoomSmart/NoYTPremium) | Removes Premium upsell alerts | 🟡 Mostly native (`Ads.x` promosheet handlers) — bundle as belt-and-braces |
| **OpenYoutubeAndShorts** | [CrossiiDev-Studio/OpenYoutubeAndShorts](https://github.com/CrossiiDev-Studio/OpenYoutubeAndShorts) | appex for sideloaded YT | 🟢 Same shape as the Safari extension we already ship — optional |
| **YTNoPaidPromo** | [PoomSmart/YTNoPaidPromo](https://github.com/PoomSmart/YTNoPaidPromo) | Hides the "paid promotion" banner | ⛔ Skip — native `PaidPromoOverlay` group already does this |
| **YTIcons** | [PoomSmart/YTIcons](https://github.com/PoomSmart/YTIcons) | Lists every `YTIIcon` icon | ⛔ Skip — a developer tool, not a user feature |
| **YouRememberCaption** | *no public source* | Remembers your caption choice | ⚠️ Not on GitHub (404 on every attempt) — prebuilt-only, so no license/build vetting. Our `DisablesCaptions` is the opposite switch today; porting natively is cleaner |
| **LowContrastMode** | [arichornlover/YTLowContrastMode](https://github.com/arichornlover/YTLowContrastMode) | Low-contrast, easy-on-the-eyes UI | ⚠️ **Compatibility check first** — its own description says YouTube v17.33.2–17.38.10, and we target 21.x |
| **YTAppVersionSpoofer** | [arichornlover/YTAppVersionSpoofer](https://github.com/arichornlover/YTAppVersionSpoofer) | Spoofs the app version to dodge update prompts | ⚠️ Same caveat — description claims support only up to v19.49.7. Test before offering it |
| **NotificationsTab** | *no standalone repo* | Restores the removed notifications tab | 🔴 Only exists inside the [uYouEnhanced](https://github.com/arichornlover/uYouEnhanced) tree (GPLv3) — would be a port, not a bundle |

### How to wire one up

Mirror the existing pattern in `ipa.yml` for each: a `xxx:` boolean input → a `Clone XXX` step → build with `FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless` → `mv packages/*.deb` into the job workspace. No code changes in this repo at all.

Recommendation: add the four 🟢 rows first (YTMiniplayerEnabler, YouTimeStamp, YTReExplore, BigYTMiniPlayer), each behind its own input with `default: true` where it can't conflict with native behaviour.

---

## 2. The gaps uYouEnhanced/YTLitePlus explicitly list against YouMod

uYouEnhanced's own "Lightweight Alternative - YouMod" section names these cons. Fixing them is the highest-leverage *native* work we can do.

| # | Feature | Effort | Notes |
|---|---------|:------:|-------|
| 2.1 | **App version spoofing** | 🟡 | Bypasses the "Update required" screen. YouMod already does bundle-ID spoofing in `Sideloading.x`, so the plumbing exists; if [YTAppVersionSpoofer](https://github.com/arichornlover/YTAppVersionSpoofer) doesn't hold up on 21.x, port the idea instead. |
| 2.2 | **"Fix Google Sign-In" toggle** | 🟡 | uYouEnhanced ships a TrollStore-specific sign-in fix. Our `SSOConfiguration` / `GULKeychainStorage` / `NSBundle` hooks in `Sideloading.x` are the same area — add the toggle next to them. |
| 2.3 | **"Fix Casting" toggle** | 🟡 | A/B flags that broke Chromecast casting. A couple of `YTColdConfig`/`YTHotConfig` overrides or an `YTABConfig` preset (YTABConfig is already bundled). |
| 2.4 | **Client spoofing (innertube client)** | 🔴 | The fix for "Sign in to confirm you're not a bot" / playback errors. No standalone open-source implementation surfaced in this pass — either investigate the uYouEnhanced tree or write it natively. |
| 2.5 | **Built-in SponsorBlock** | 🟢 ✅ | iSponsorBlock was added to `ipa.yml` in `034016c`. Nothing to do unless we later want it native. |
| 2.6 | **LowContrastMode** | 🟡 | See the compat caveat in §1 before bundling; porting the `YTColor`/label hooks (same pattern as `Apperence.x`) sidesteps it. |
| 2.7 | **NotificationsTab** | 🔴 | Big and fragile (Inertube endpoints); worth doing only if we want a headline differentiator. |

---

## 3. Player features worth porting

| # | Feature | Effort | Notes |
|---|---------|:------:|-------|
| 3.1 | **Copy link at current timestamp** | 🟢 | Prefer bundling [YouTimeStamp](https://github.com/arichornlover/YouTimeStamp) (§1) over porting; if we port, `Download.x` already has `YouModCopyVideoInfo` — just append `&t=<seconds>s`. |
| 3.2 | **Remember last caption choice** | 🟡 | Source unavailable (§1), so this is port-only: persist `setActiveCaptionTrack:` instead of the current `DisablesCaptions` auto-off behaviour. |
| 3.3 | **Default quality on load** | 🟡 | YTLite's "default quality" option — start every video at a chosen height. The `OldVideoQuality` group in `Player.x` is the closest existing code. |
| 3.4 | **Preferred audio track / language** | 🟡 | YTLite has "preferred audio track". We only expose audio *format* at download time (`Download.x`), never for playback. |
| 3.5 | **Mute button + overlay buttons** | 🟢 ✅ | YouMute / YouQuality / YouSpeed are already wired through `ipa.yml`. |
| 3.6 | **Miniplayer for all videos** | 🟢 | Bundle `YTMiniplayerEnabler` (§1) — or port, using the `ForceMiniPlayer` group in `Player.x` as the template. |
| 3.7 | **Hold-to-seek speed** | 🟢 ✅ | Already an `ipa.yml` toggle. |

---

## 4. Feed / navigation features

| # | Feature | Effort | Notes |
|---|---------|:------:|-------|
| 4.1 | **Tab bar reordering** | 🟡 | **The README already claims this** ("Tab bar (reorder, add/remove buttons)") but `Tabbar.x` only *hides* tabs and sets the startup tab. Implement it by reordering `itemsArray` in `YTPivotBarView setRenderer:` (the hide logic is already there), or drop the claim from the README. |
| 4.2 | **Open Shorts in the regular player** | 🟡 | There is a commented-out `shortsToRegular` sketch in `Player.x` — finish it (vnd.youtube deep link or redirect the reel endpoint) as the "no more Shorts UI" option. |
| 4.3 | **Shorts-only mode** | 🔴 | YTLite has it; the inverse of 4.2. Reuses the `Shorts` filter group in `Feed.x`. |
| 4.4 | **Explore tab instead of a hole** | 🟢 | Bundle `YTReExplore` (§1) alongside our `HideShortsTab`. |
| 4.5 | **Hide Shorts from search results** | 🟡 | We hide the shelf, the tab and many buttons, but Shorts still dominate search. Filter `YTISearchSectionRenderer` contents the same way `Ads.x` filters ad renderers. |
| 4.6 | **Hide Mix / "Trending" / music shelves** | 🟢 | Extend `Feed.x`'s `filteredArray` — it already recognises shelf renderers; add pivot identifiers for mix/trending shelves as toggles. |
| 4.7 | **Hide the comments panel** | 🟢 | We can hide the Shorts comment *button* but not the watch-page comments section. One `_ASDisplayView` identifier check in `Sideloading.x`. |

---

## 5. The download manager (biggest differentiator left)

YTLite's headline feature is a real download manager. YouMod has a solid downloader (range requests, 8-way chunking, AVFoundation merge, Photos export) but:

- **No queue** — starting a second download just shows *"Already downloading"*.
- **No library / resume** — files land in `Documents/YouMod Downloads` but there's no in-app list, no resume, no cancel, no delete, no offline playback.
- **No progress history** — only a transient alert.

Suggested steps, smallest first:

1. 🟡 **Queue** — turn `YouModDownloadCoordinator` from a singleton-active model into a serial queue of jobs. Mostly bookkeeping; the range downloader already handles a whole file.
2. 🔴 **Library screen** — a `YTSettingsPickerViewController`-style section (we already build settings screens from scratch in `Settings.x`) listing `Documents/YouMod Downloads`, with share / delete / play (`AVPlayer`).
3. 🔴 **Resume** — persist downloaded byte ranges per job next to the file (`.youmod.part` + offsets). The chunk model in `YouModRangeDownloader` already thinks in ranges, so this is a natural fit.

---

## 6. Polish / quality-of-life

| # | Item | Effort | Notes |
|---|------|:------:|-------|
| 6.1 | **"Restart required" hint** | 🟢 | Groups gated in `%ctor` (`OldVideoQuality`, `Gestures`, `OLEDTheme`, `PaidPromoOverlay`, …) only apply after an app restart. YTLite shows a prompt; we should at least say so in the setting description. |
| 6.2 | **Localise the download UI** | 🟡 | Every string in `Download.x` ("Download video", "Save to Photos", …) is hardcoded English while settings are translated into 35 languages. |
| 6.3 | **Single source for default settings** | 🟢 ✅ | `YouModRegisterDefaults()` — see `Files/Settings.x`. |
| 6.4 | **Safe settings import** | 🟢 ✅ | Import now validates before wiping — see `Files/YouModPerferences.x`. |
| 6.5 | **CI: pin third-party clones** | 🟡 | `ipa.yml` clones ~20 repos at `HEAD` plus `pipx install …/archive/main.zip`. Pinning to SHAs makes releases reproducible and avoids a supply-chain surprise. Same applies to anything new added from §1. |
| 6.6 | **Auto-clear cache default** | 🟢 | `AutoClearCache` defaults to `YES`, so every launch throws away YouTube's whole cache (slower cold starts). Consider defaulting to `NO` and letting users opt in. |

---

## 7. Suggested order of attack

1. **§1's four 🟢 bundles** — pure YAML, no code, immediately visible features.
2. **6.1 + 3.2 + 4.7** — small native wins.
3. **4.1 (tab reorder)** — the README promises it.
4. **2.1 version spoofing + 2.2 sign-in fix** — directly closes the two cons listed against us upstream (after verifying YTAppVersionSpoofer on 21.x).
5. **5.1 download queue** — sets up the library screen.
6. **2.4 client spoofing** — the hardest, but removes the biggest "uYouEnhanced is still needed" complaint.
