#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BUILD_DIR="$PROJECT_DIR/flatpak-build"
BUNDLE_DIR="$PROJECT_DIR/flatpak-repo"
CARGO_CACHE="/tmp/flatpak-cargo"
RUSTUP_CACHE="/tmp/flatpak-rustup"

mkdir -p "$BUILD_DIR" "$CARGO_CACHE" "$RUSTUP_CACHE"

flatpak build-init "$BUILD_DIR" \
  org.anythingdevteam.wallpapersearcher \
  org.kde.Sdk \
  org.kde.Platform \
  6.10

flatpak build --share=network \
  --bind-mount=/run/cargo="$CARGO_CACHE" \
  --bind-mount=/run/rustup="$RUSTUP_CACHE" \
  --bind-mount=/run/build="$PROJECT_DIR" \
  "$BUILD_DIR" /bin/bash -e -c '
set -euo pipefail

export CARGO_HOME=/run/cargo
export RUSTUP_HOME=/run/rustup
export PATH="$CARGO_HOME/bin:$PATH"

if ! command -v rustc &>/dev/null; then
  curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$CARGO_HOME/env"
fi

cd /run/build
cargo build --release
install -Dm755 target/release/wallpapersearcher /app/bin/wallpapersearcher
install -Dm644 flatpak/org.anythingdevteam.wallpapersearcher.desktop \
  /app/share/applications/org.anythingdevteam.wallpapersearcher.desktop
install -Dm644 flatpak/org.anythingdevteam.wallpapersearcher.metainfo.xml \
  /app/share/metainfo/org.anythingdevteam.wallpapersearcher.metainfo.xml
install -Dm644 flatpak/icons/hicolor/scalable/apps/org.anythingdevteam.wallpapersearcher.svg \
  /app/share/icons/hicolor/scalable/apps/org.anythingdevteam.wallpapersearcher.svg
'

flatpak build-finish "$BUILD_DIR" \
  --share=network \
  --share=ipc \
  --socket=x11 \
  --socket=wayland \
  --device=dri \
  --filesystem=home \
  --filesystem=xdg-run/dconf \
  --filesystem=~/.config/dconf:ro

flatpak build-export "$BUNDLE_DIR" "$BUILD_DIR" stable

echo "Flatpak bundle created successfully."
echo "Install with: flatpak --user install $BUNDLE_DIR org.anythingdevteam.wallpapersearcher"
