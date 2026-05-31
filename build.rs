use cxx_qt_build::{CxxQtBuilder, QmlModule};
use std::path::PathBuf;

fn main() {
    CxxQtBuilder::new_qml_module(
        QmlModule::new("com.wallpapersearcher")
            .qml_file("qml/main.qml")
            .qml_file("qml/SearchBar.qml")
            .qml_file("qml/SettingsDialog.qml")
            .qml_file("qml/AboutDialog.qml")
            .qml_file("qml/SearchIdeas.qml")
            .qml_file("qml/FavoritesSection.qml")
            .qml_file("qml/Lang.qml")
            .qml_file("qml/FullPreview.qml"),
    )
    .qt_module("Network")
    .files(["src/app.rs"])
    .build();

    let out = PathBuf::from(std::env::var("OUT_DIR").unwrap());
    let is_windows = std::env::var("CARGO_CFG_TARGET_OS").unwrap() == "windows";
    let ext = if is_windows { "lib" } else { "a" };
    let prefix = if is_windows { "" } else { "lib" };

    for name in [
        "wallpapersearcher-cxxqt-generated",
        "cxx-qt-call-init-crate_wallpapersearcher",
        "cxx-qt-call-init-qml_module_com_wallpapersearcher",
    ] {
        let lib = format!("{}{}.{}", prefix, name, ext);
        let full = out.join(&lib);
        if is_windows {
            println!("cargo::rustc-link-arg-bins=/WHOLEARCHIVE:{}", full.display());
        } else {
            println!("cargo::rustc-link-arg-bins=-Wl,--whole-archive");
            println!("cargo::rustc-link-arg-bins=-Wl,{}", full.display());
            println!("cargo::rustc-link-arg-bins=-Wl,--no-whole-archive");
        }
    }
}
