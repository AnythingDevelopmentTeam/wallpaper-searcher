# Wallpaper Searcher

Desktop wallpaper search app — **Rust** + **Qt 6** (QML) + **cxx-qt**.

Searches [Wallhaven](https://wallhaven.cc/) (free, no API key required) with **Safe Search** enforced.

## Screenshot

```
┌─────────────────────────────────────┐
│  🖼 Wallpaper Searcher              │
│  [forest, minimal…]       [🔍 Искать] │
├─────────────────────────────────────┤
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
│  │ img │ │ img │ │ img │ │ img │  │
│  └─────┘ └─────┘ └─────┘ └─────┘  │
│  ┌─────┐ ┌─────┐                  │
│  │ img │ │ img │                  │
│  └─────┘ └─────┘                  │
└─────────────────────────────────────┘
✓ Safe Search
```

## Features

- Search wallpapers by keyword
- Dark theme (Catppuccin Mocha palette)
- 4-column grid with smooth animations
- Hover to see resolution, click to open in browser
- **💾 Save** button on hover — downloads full image to `~/Pictures/Wallpapers/`
- Safe Search enforced via Wallhaven `purity=100` (SFW only)

## Requirements

- **Rust** 1.75+
- **Qt 6** with QML modules: `qt6-declarative-dev`, `qml6-module-qtquick-*`
- **Cargo** — build system

### Ubuntu 24.04

```bash
sudo apt install -y \
  qt6-base-dev qt6-declarative-dev \
  qml6-module-qtquick \
  qml6-module-qtquick-controls \
  qml6-module-qtquick-layouts \
  qml6-module-qtquick-window \
  qml6-module-qtquick-templates \
  qml6-module-qtqml-workerscript
```

## Build & Run

```bash
cargo build --release
./target/release/wallpapersearcher
```

Offscreen mode (no display):

```bash
QT_QPA_PLATFORM=offscreen ./target/release/wallpapersearcher
```

## Architecture

```
┌──────────┐   ┌──────────┐   ┌──────────┐
│   Rust   │   │  C++     │   │   QML    │
│ lib.rs   │◄──┤ cxx-qt   ├──►│ main.qml │
│ reqwest  │   │ bridge   │   │ UI       │
│ Wallhaven│   │ QObject  │   │          │
└──────────┘   └──────────┘   └──────────┘
```

- `src/lib.rs` — `WallpaperSearch` QObject (cxx-qt bridge), HTTP requests to Wallhaven
- `src/main.rs` — entry point, includes `lib.rs` for link-order compatibility
- `build.rs` — CxxQtBuilder + QmlModule
- `qml/main.qml` — full UI (Window, TextField, GridView, save button)

## Stack

| Component | Version |
|-----------|---------|
| Rust      | 1.75+   |
| Qt        | 6.4+    |
| cxx-qt    | 0.8     |
| reqwest   | 0.12    |
| Wallhaven | v1 (free, no key) |
