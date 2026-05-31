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

    for lib in [
        "libwallpapersearcher-cxxqt-generated.a",
        "libcxx-qt-call-init-crate_wallpapersearcher.a",
        "libcxx-qt-call-init-qml_module_com_wallpapersearcher.a",
    ] {
        println!("cargo::rustc-link-arg-bins=-Wl,--whole-archive");
        println!("cargo::rustc-link-arg-bins=-Wl,{}", out.join(lib).display());
        println!("cargo::rustc-link-arg-bins=-Wl,--no-whole-archive");
    }
}
