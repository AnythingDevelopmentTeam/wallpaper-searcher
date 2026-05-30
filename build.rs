use cxx_qt_build::{CxxQtBuilder, QmlModule};
use std::path::PathBuf;

fn main() {
    CxxQtBuilder::new_qml_module(
        QmlModule::new("com.wallpapersearcher")
            .qml_file("qml/main.qml"),
    )
    .qt_module("Network")
    .files(["src/app.rs"])
    .build();

    // При использовании `include!("lib.rs")` в main.rs бинарный таргет не
    // наследует `cargo:rustc-link-lib=` от скрипта сборки (они применяются
    // только к lib-таргету). Явно добавляем сгенерированные .a-библиотеки
    // в команду линковки бинарника через `cargo::rustc-link-arg-bins`.
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
