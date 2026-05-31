# Wallpaper Searcher

Desktop wallpaper search app.

## Features

- Search wallpapers by keyword
- 4-column grid with smooth animations
- Hover to see resolution, click to open in browser
- **💾 Save** button on hover — downloads full image to `~/Pictures/Wallpapers/`

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

## Stack

| Component | Version |
|-----------|---------|
| Rust      | 1.75+   |
| Qt        | 6.4+    |
| cxx-qt    | 0.8     |
| reqwest   | 0.12    |
