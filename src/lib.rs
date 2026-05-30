use core::pin::Pin;
use cxx_qt_lib::QString;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[cxx_qt::bridge]
pub mod qobject {

    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    extern "RustQt" {

        #[qobject]
        #[qml_element]
        #[qproperty(QString, query)]
        #[qproperty(QString, results_json)]
        #[qproperty(bool, loading)]
        #[qproperty(QString, error_message)]
        #[qproperty(QString, save_message)]
        type WallpaperSearch = super::WallpaperSearchRust;

        #[qinvokable]
        fn search(self: Pin<&mut Self>, query: &QString);

        #[qinvokable]
        fn saveImage(self: Pin<&mut Self>, url: &QString);

        #[qsignal]
        fn searchCompleted(self: Pin<&mut Self>);

        #[qsignal]
        fn searchError(self: Pin<&mut Self>, error: QString);

        #[qsignal]
        fn saveCompleted(self: Pin<&mut Self>, path: QString);

        #[qsignal]
        fn saveError(self: Pin<&mut Self>, error: QString);
    }
}

#[derive(Default)]
pub struct WallpaperSearchRust {
    query: QString,
    results_json: QString,
    loading: bool,
    error_message: QString,
    save_message: QString,
}

#[derive(Debug, Deserialize)]
struct WallhavenResponse {
    data: Vec<WallhavenWallpaper>,
}

#[derive(Debug, Deserialize)]
struct WallhavenWallpaper {
    #[serde(rename = "url")]
    page: String,
    thumbs: WallhavenThumbs,
    #[serde(rename = "path")]
    full: String,
    resolution: String,
}

#[derive(Debug, Deserialize)]
struct WallhavenThumbs {
    large: String,
}

#[derive(Debug, Serialize)]
struct WallpaperResult {
    preview: String,
    full: String,
    author: String,
    page: String,
}

impl qobject::WallpaperSearch {

    pub fn saveImage(mut self: Pin<&mut Self>, url: &QString) {
        let url_str = url.to_string();

        // Определяем папку для сохранения
        let save_dir = save_dir();
        if let Err(e) = fs::create_dir_all(&save_dir) {
            let msg = format!("Не удалось создать папку: {}", e);
            self.as_mut().set_save_message(QString::from(&msg));
            self.as_mut().saveError(QString::from(&msg));
            return;
        }

        // Имя файла из URL
        let filename = url_str
            .rsplit('/')
            .next()
            .unwrap_or("wallpaper.jpg");
        let filepath = save_dir.join(filename);

        // Скачиваем
        let client = reqwest::blocking::Client::new();
        match client.get(&url_str).send() {
            Ok(resp) => {
                let bytes = match resp.bytes() {
                    Ok(b) => b,
                    Err(e) => {
                        let msg = format!("Ошибка скачивания: {}", e);
                        self.as_mut().set_save_message(QString::from(&msg));
                        self.as_mut().saveError(QString::from(&msg));
                        return;
                    }
                };
                match fs::write(&filepath, &bytes) {
                    Ok(_) => {
                        let msg = filepath.to_string_lossy().to_string();
                        self.as_mut().set_save_message(QString::from(&msg));
                        self.as_mut().saveCompleted(QString::from(&msg));
                    }
                    Err(e) => {
                        let msg = format!("Ошибка записи файла: {}", e);
                        self.as_mut().set_save_message(QString::from(&msg));
                        self.as_mut().saveError(QString::from(&msg));
                    }
                }
            }
            Err(e) => {
                let msg = format!("Сетевая ошибка: {}", e);
                self.as_mut().set_save_message(QString::from(&msg));
                self.as_mut().saveError(QString::from(&msg));
            }
        }
    }

    pub fn search(mut self: Pin<&mut Self>, query: &QString) {
        let query_str = query.to_string();

        self.as_mut().set_query(QString::from(&query_str));
        self.as_mut().set_loading(true);
        self.as_mut().set_error_message(QString::from(""));
        self.as_mut().set_results_json(QString::from(""));

        let client = reqwest::blocking::Client::new();
        let url = "https://wallhaven.cc/api/v1/search";

        let params = [
            ("q", query_str.as_str()),
            ("categories", "111"),
            ("purity", "100"),
            ("sorting", "relevance"),
            ("atleast", "1920x1080"),
        ];

        let response = client.get(url).query(&params).send();

        match response {
            Ok(resp) => {
                if !resp.status().is_success() {
                    let msg = format!("API вернул ошибку: {}", resp.status());
                    self.as_mut().set_loading(false);
                    self.as_mut().set_error_message(QString::from(&msg));
                    self.as_mut().searchError(QString::from(&msg));
                    return;
                }

                match resp.json::<WallhavenResponse>() {
                    Ok(wh_data) => {
                        let normalized: Vec<WallpaperResult> = wh_data
                            .data
                            .into_iter()
                            .map(|w| WallpaperResult {
                                preview: w.thumbs.large,
                                full: w.full,
                                author: w.resolution,
                                page: w.page,
                            })
                            .collect();

                        let json = serde_json::to_string(&normalized).unwrap_or_default();
                        self.as_mut().set_results_json(QString::from(&json));
                        self.as_mut().set_loading(false);
                        self.as_mut().searchCompleted();
                    }
                    Err(e) => {
                        let msg = format!("Ошибка парсинга JSON: {}", e);
                        self.as_mut().set_loading(false);
                        self.as_mut().set_error_message(QString::from(&msg));
                        self.as_mut().searchError(QString::from(&msg));
                    }
                }
            }
            Err(e) => {
                let msg = format!("Сетевая ошибка: {}", e);
                self.as_mut().set_loading(false);
                self.as_mut().set_error_message(QString::from(&msg));
                self.as_mut().searchError(QString::from(&msg));
            }
        }
    }
}

fn save_dir() -> PathBuf {
    let home = std::env::var("HOME")
        .or_else(|_| std::env::var("USERPROFILE"))
        .unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(home).join("Pictures").join("Wallpapers")
}
