#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  cachyos-blackshield ⚫🛡 — Blackshield Mercenary theme pack installer
#  Steel over spectacle. Run: ./install.sh [phase]
#
#  Phases:  packages | fonts | configs | kde | system | wallpapers | all
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
C="\033[1;31m"; S="\033[1;37m"; D="\033[2m"; X="\033[0m"

ok()   { echo -e "${C}⚫${X} ${S}$*${X}"; }
note() { echo -e "${D}$*${X}"; }
die()  { echo -e "${C}[!]${X} $*"; exit 1; }

# ───────────────────────────────────────────────────────────────────
phase="${1:-all}"

do_packages() {
  ok "packages — installing theme deps"
  sudo pacman -S --needed --noconfirm - < "$REPO_DIR/manifest/packages.txt"
}

do_fonts() {
  ok "fonts — shipping bundled fonts (~/.local/share/fonts)"
  mkdir -p ~/.local/share/fonts
  cp -rf "$REPO_DIR/configs/fonts"/. ~/.local/share/fonts/
  fc-cache -f >/dev/null 2>&1 || true
  note "installed: EB Garamond, Pirata One, Xanh Mono, 3270 Nerd Font"
}

do_configs() {
  ok "configs — user-level configs (backups as *.blackshield.bak)"
  local CFG=~/.config

  for app in alacritty kitty fish fastfetch; do
    if [[ -d "$REPO_DIR/configs/$app" ]]; then
      mkdir -p "$CFG/$app"
      for f in "$REPO_DIR/configs/$app"/*; do
        [[ -e "$f" ]] || continue
        local target="$CFG/$app/$(basename "$f")"
        [[ -f "$target" ]] && ! [[ -f "$target.blackshield.bak" ]] && cp -f "$target" "$target.blackshield.bak"
        cp -f "$f" "$target"
      done
      ok "  $app"
    fi
  done

  # ghostty — repo ships config.ghostty but the app reads ~/.config/ghostty/config
  if [[ -f "$REPO_DIR/configs/ghostty/config.ghostty" ]]; then
    mkdir -p "$CFG/ghostty"
    [[ -f "$CFG/ghostty/config" ]] && ! [[ -f "$CFG/ghostty/config.blackshield.bak" ]] && cp -f "$CFG/ghostty/config" "$CFG/ghostty/config.blackshield.bak"
    cp -f "$REPO_DIR/configs/ghostty/config.ghostty" "$CFG/ghostty/config"
    ok "  ghostty"
  fi

  # neovim — colorscheme only; init.lua is a reference, never clobber
  mkdir -p "$CFG/nvim/colors"
  cp -f "$REPO_DIR/configs/nvim/colors/blackshield.lua" "$CFG/nvim/colors/blackshield.lua" 2>/dev/null \
    || cp -f "$REPO_DIR/configs/nvim/lua/colors/blackshield.lua" "$CFG/nvim/lua/colors/blackshield.lua" 2>/dev/null \
    || true
  ok "  nvim (blackshield colorscheme — merge init.lua manually if you want it)"

  # git — template with placeholders (never overwrite identity)
  mkdir -p "$CFG/git"
  [[ -f "$CFG/git/config" ]] && ! [[ -f "$CFG/git/config.blackshield.bak" ]] && cp -f "$CFG/git/config" "$CFG/git/config.blackshield.bak"
  cp -f "$REPO_DIR/configs/git/gitconfig" "$CFG/git/config"
  ok "  git (template — fill in your name/email)"

  # browsers — manual steps documented in docs/BROWSERS.md
  note "  browsers: firefox/Chromium theming is manual — see docs/BROWSERS.md"

  # opencode themes
  if [[ -d "$REPO_DIR/configs/opencode/themes" ]]; then
    mkdir -p "$CFG/opencode/themes"
    cp -f "$REPO_DIR/configs/opencode/themes/blackshield.json" "$CFG/opencode/themes/" 2>/dev/null || true
    ok "  opencode (blackshield theme)"
  fi

  # gtk + xsettingsd
  [[ -f "$REPO_DIR/configs/xsettingsd/xsettingsd.conf" ]] && { mkdir -p "$CFG/xsettingsd"; cp -f "$REPO_DIR/configs/xsettingsd/xsettingsd.conf" "$CFG/xsettingsd/"; ok "  xsettingsd"; }
  ok "  gtk (see configs/kde/gtk*.ini as reference)"
}

do_kde() {
  ok "kde — Blackshield Plasma theme stack (user-level)"
  local SHARE=~/.local/share

  mkdir -p "$SHARE/plasma/desktoptheme" "$SHARE/aurorae/themes" "$SHARE/plasma/look-and-feel" "$SHARE/color-schemes" "$SHARE/icons"
  [[ -d "$REPO_DIR/configs/kde/desktoptheme/Blackshield" ]] && cp -rf "$REPO_DIR/configs/kde/desktoptheme/Blackshield" "$SHARE/plasma/desktoptheme/"
  [[ -d "$REPO_DIR/configs/kde/aurorae/Blackshield" ]] && cp -rf "$REPO_DIR/configs/kde/aurorae/Blackshield" "$SHARE/aurorae/themes/"
  [[ -d "$REPO_DIR/configs/kde/look-and-feel/Sweet-Blackshield" ]] && cp -rf "$REPO_DIR/configs/kde/look-and-feel/Sweet-Blackshield" "$SHARE/plasma/look-and-feel/"
  [[ -d "$REPO_DIR/configs/icons/Blackshield" ]] && cp -rf "$REPO_DIR/configs/icons/Blackshield" "$SHARE/icons/"
  [[ -d "$REPO_DIR/configs/icons/candidates/hand-of-evil" ]] && cp -rf "$REPO_DIR/configs/icons/candidates/hand-of-evil" "$SHARE/icons/"
  cp -f "$REPO_DIR/configs/kde/color-schemes/Blackshield.colors" "$SHARE/color-schemes/" 2>/dev/null || true

  # global Plasma configs (backup originals)
  local CFG=~/.config
  for f in kdeglobals kwinrc ksplashrc; do
    [[ -f "$REPO_DIR/configs/kde/$f" ]] || continue
    [[ -f "$CFG/$f" ]] && ! [[ -f "$CFG/$f.blackshield.bak" ]] && cp -f "$CFG/$f" "$CFG/$f.blackshield.bak"
    cp -f "$REPO_DIR/configs/kde/$f" "$CFG/$f"
  done

  # apply theme bits immediately
  command -v plasma-apply-colorscheme >/dev/null 2>&1 && plasma-apply-colorscheme Blackshield >/dev/null 2>&1 || true
  command -v plasma-apply-desktoptheme >/dev/null 2>&1 && plasma-apply-desktoptheme Blackshield >/dev/null 2>&1 || true
  ok "  applied — restart Plasma (or log out/in) to pick up window decorations + LAF"
}

do_system() {
  ok "system — boot + login livery (sudo)"
  # Plymouth
  if [[ -d "$REPO_DIR/configs/plymouth/blackshield" && -f /usr/share/plymouth/themes ]]; then
    sudo mkdir -p /usr/share/plymouth/themes/blackshield
    sudo cp -rf "$REPO_DIR/configs/plymouth/blackshield"/. /usr/share/plymouth/themes/blackshield/
    sudo plymouth-set-default-theme blackshield >/dev/null 2>&1 || true
    ok "  plymouth: blackshield splash set"
  fi
  # Limine branding
  if [[ -f "$REPO_DIR/configs/limine/limine-splash-blackshield.png" ]]; then
    if [[ -f /boot/limine.conf || -d /boot/limine ]]; then
      sudo cp -f "$REPO_DIR/configs/limine/limine-splash-blackshield.png" /boot/limine-splash-blackshield.png 2>/dev/null || true
      note "  limine: splash copied — wire the path into /boot/limine.conf manually"
    else
      note "  limine: no Limine install found — skipped"
    fi
  fi
  # Plasma login greeter
  if [[ -f "$REPO_DIR/configs/system/plasmalogin-greeter-kdeglobals" && -d /usr/share/sddm ]]; then
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp -f "$REPO_DIR/configs/system/plasmalogin-greeter-kdeglobals" /etc/sddm.conf.d/blackshield-greeter.conf 2>/dev/null || true
    ok "  sddm greeter: blackshield kdeglobals copied"
  fi
}

do_wallpapers() {
  ok "wallpapers — deploy + apply"
  mkdir -p ~/Pictures/blackshield ~/Pictures/blackshield-lock-login
  cp -f "$REPO_DIR"/wallpapers/blackshield/*.png ~/Pictures/blackshield/ 2>/dev/null || true
  cp -f "$REPO_DIR"/wallpapers/blackshield-lock-login/*.png ~/Pictures/blackshield-lock-login/ 2>/dev/null || true
  local primary="$HOME/Pictures/blackshield/blackshield-primary-1920x1080.png"
  [[ -f "$primary" ]] || primary="$HOME/Pictures/blackshield/blackshield-primary-2560x1440.png"
  if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
    plasma-apply-wallpaperimage "$primary" >/dev/null 2>&1 && ok "  applied: $primary" || note "  copy done; apply wallpaper manually (system settings → wallpaper)"
  else
    note "  copied to ~/Pictures/blackshield — set manually in System Settings"
  fi
}

do_all() {
  do_packages; do_fonts; do_configs; do_kde; do_system; do_wallpapers
}

case "$phase" in
  packages)  do_packages ;;
  fonts)     do_fonts ;;
  configs)   do_configs ;;
  kde)       do_kde ;;
  system)    do_system ;;
  wallpapers) do_wallpapers ;;
  all|"")    do_all ;;
  *) die "unknown phase: $phase (packages|fonts|configs|kde|system|wallpapers|all)" ;;
esac

echo
ok "Blackshield theme pack deployed. Log out/in (or reboot) for the full livery."
note "The shield holds. ⚫🛡"