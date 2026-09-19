# Browser Themes — Blackshield ⚫🛡

Browser chrome matching the KDE / terminal / Limine / Plymouth stack.

Palette canon: ember-black `#0B0D12` · steel `#8F959C` · blood `#C1121F` ·
bone `#D8D3C8` · banner blood `#E0555F` · border iron `#242C3A`.

## Firefox

**What ships:** `configs/browsers/firefox/`

- `chrome/userChrome.css` — toolbars, tabs, URL bar with blood accent, menus,
  sidebar, findbar, scrollbars, tooltips.
- `chrome/userContent.css` — `about:newtab` / `about:home` /
  `about:privatebrowsing` / reader mode. New tab uses the Blackshield art
  (`chrome/ntp_background.png`).
- `user.js` — enables `toolkit.legacyUserProfileCustomizations.stylesheets`
  (required for userChrome) + dark devtools.

**Install (manual):**

1. Open `about:config`, set `toolkit.legacyUserProfileCustomizations.stylesheets` → `true`
   (or copy `user.js` into your profile and restart Firefox).
2. Copy `chrome/` into your profile directory:
   ```
   ~/.mozilla/firefox/<profile>/chrome/
   ```
3. Restart Firefox.

## Chromium

**What ships:** `configs/browsers/chromium/blackshield/` — an unpacked theme
(`manifest.json` + `ntp_background.png`).

**Install:**

1. Open `chrome://extensions`
2. Enable **Developer mode** (top-right)
3. **Load unpacked** → select `configs/browsers/chromium/blackshield/`

The shield holds. ⚫🛡