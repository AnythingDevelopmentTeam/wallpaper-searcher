#![allow(non_snake_case, dead_code)]

include!("app.rs");

use cxx_qt_lib::{QGuiApplication, QQmlApplicationEngine, QUrl};

fn main() {
    cxx_qt::init_crate!(cxx_qt_lib);
    cxx_qt::init_crate!(cxx_qt);
    cxx_qt::init_qml_module!("com.wallpapersearcher");

    let mut app = QGuiApplication::new();
    let mut engine = QQmlApplicationEngine::new();

    if let Some(engine) = engine.as_mut() {
        engine.load(&QUrl::from(
            "qrc:/qt/qml/com/wallpapersearcher/qml/main.qml",
        ));
    }

    if let Some(app) = app.as_mut() {
        app.exec();
    }
}
