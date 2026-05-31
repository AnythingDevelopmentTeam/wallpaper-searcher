use std::pin::Pin;
use cxx_qt_lib::QString;
use image::GenericImageView;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

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
        #[qproperty(QString, categories)]
        #[qproperty(QString, purity)]
        #[qproperty(QString, sorting)]
        #[qproperty(QString, atleast)]
        #[qproperty(QString, favorites_json)]
        #[qproperty(QString, search_source)]
        #[qproperty(QString, unsplash_key)]
        #[qproperty(QString, language)]
        type WallpaperSearch = super::WallpaperSearchRust;

        #[qinvokable]
        fn search(self: Pin<&mut Self>, query: &QString);

        #[qinvokable]
        fn save_image(self: Pin<&mut Self>, url: &QString);

        #[qinvokable]
        fn apply_wallpaper(self: Pin<&mut Self>, url: &QString, screen_w: i32, screen_h: i32);

        #[qinvokable]
        fn add_favorite(self: Pin<&mut Self>, preview: &QString, full: &QString, author: &QString, page: &QString);

        #[qinvokable]
        fn remove_favorite(self: Pin<&mut Self>, full: &QString);

        #[qsignal]
        fn searchCompleted(self: Pin<&mut Self>);

        #[qsignal]
        fn searchError(self: Pin<&mut Self>, error: QString);

        #[qsignal]
        fn saveCompleted(self: Pin<&mut Self>, path: QString);

        #[qsignal]
        fn saveError(self: Pin<&mut Self>, error: QString);

        #[qsignal]
        fn applyCompleted(self: Pin<&mut Self>, path: QString);

        #[qsignal]
        fn applyError(self: Pin<&mut Self>, error: QString);

        #[qsignal]
        fn favoritesChanged(self: Pin<&mut Self>);
    }
}

pub struct WallpaperSearchRust {
    query: QString,
    results_json: QString,
    loading: bool,
    error_message: QString,
    save_message: QString,
    categories: QString,
    purity: QString,
    sorting: QString,
    atleast: QString,
    favorites_json: QString,
    search_source: QString,
    unsplash_key: QString,
    language: QString,
}

impl Default for WallpaperSearchRust {
    fn default() -> Self {
        Self {
            language: QString::from("ru"),
            query: QString::from(""),
            results_json: QString::from(""),
            loading: false,
            error_message: QString::from(""),
            save_message: QString::from(""),
            categories: QString::from(""),
            purity: QString::from(""),
            sorting: QString::from(""),
            atleast: QString::from(""),
            favorites_json: QString::from(""),
            search_source: QString::from(""),
            unsplash_key: QString::from(""),
        }
    }
}

// Wallhaven

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

// Unsplash

#[derive(Debug, Deserialize)]
struct UnsplashResponse {
    results: Vec<UnsplashWallpaper>,
}

#[derive(Debug, Deserialize)]
struct UnsplashWallpaper {
    urls: UnsplashUrls,
    user: UnsplashUser,
    links: UnsplashLinks,
}

#[derive(Debug, Deserialize)]
struct UnsplashUrls {
    small: String,
    full: String,
}

#[derive(Debug, Deserialize)]
struct UnsplashUser {
    name: String,
}

#[derive(Debug, Deserialize)]
struct UnsplashLinks {
    #[serde(rename = "html")]
    page: String,
}

// Common

#[derive(Debug, Serialize, Deserialize)]
struct WallpaperResult {
    preview: String,
    full: String,
    author: String,
    page: String,
}

impl qobject::WallpaperSearch {

    pub fn save_image(mut self: Pin<&mut Self>, url: &QString) {
        let url_str = url.to_string();
        let save_dir = save_dir();
        if let Err(e) = fs::create_dir_all(&save_dir) {
            self.report_save_error(&format!("Не удалось создать папку: {}", e));
            return;
        }
        let filename = url_str.rsplit('/').next().unwrap_or("wallpaper.jpg");
        let filepath = save_dir.join(filename);
        match download_image(&url_str) {
            Ok(bytes) => {
                if let Err(msg) = write_file(&filepath, &bytes) {
                    self.report_save_error(&msg);
                    return;
                }
                let path = filepath.to_string_lossy().to_string();
                self.as_mut().set_save_message(QString::from(&path));
                self.as_mut().saveCompleted(QString::from(&path));
            }
            Err(msg) => self.report_save_error(&msg),
        }
    }

    pub fn apply_wallpaper(mut self: Pin<&mut Self>, url: &QString, screen_w: i32, screen_h: i32) {
        let url_str = url.to_string();
        let sw = screen_w.max(1) as u32;
        let sh = screen_h.max(1) as u32;
        let save_dir = save_dir();
        if let Err(e) = fs::create_dir_all(&save_dir) {
            self.report_apply_error(&format!("Не удалось создать папку: {}", e));
            return;
        }
        let filename = url_str.rsplit('/').next().unwrap_or("wallpaper.jpg");
        let filepath = save_dir.join(filename);
        match download_image(&url_str) {
            Ok(bytes) => {
                if let Err(msg) = write_file(&filepath, &bytes) {
                    self.report_apply_error(&msg);
                    return;
                }
                if let Err(msg) = crop_image(&filepath, sw, sh) {
                    self.report_apply_error(&msg);
                    return;
                }
                match set_wallpaper(&filepath) {
                    Ok(()) => {
                        let path = filepath.to_string_lossy().to_string();
                        self.as_mut().set_save_message(QString::from(&path));
                        self.as_mut().applyCompleted(QString::from(&path));
                    }
                    Err(msg) => self.report_apply_error(&msg),
                }
            }
            Err(msg) => self.report_apply_error(&msg),
        }
    }

    fn report_save_error(mut self: Pin<&mut Self>, msg: &str) {
        self.as_mut().set_save_message(QString::from(msg));
        self.as_mut().saveError(QString::from(msg));
    }

    fn report_apply_error(mut self: Pin<&mut Self>, msg: &str) {
        self.as_mut().set_save_message(QString::from(msg));
        self.as_mut().applyError(QString::from(msg));
    }

    pub fn search(mut self: Pin<&mut Self>, query: &QString) {
        let query_str = query.to_string();
        self.as_mut().set_query(QString::from(&query_str));
        self.as_mut().set_loading(true);
        self.as_mut().set_error_message(QString::from(""));
        self.as_mut().set_results_json(QString::from(""));

        let source = self.as_mut().search_source().to_string();
        match source.as_str() {
            "unsplash" => self.as_mut().search_unsplash(query),
            _ => self.as_mut().search_wallhaven(query),
        }
    }

    fn emit_search_error(mut self: Pin<&mut Self>, msg: &str) {
        self.as_mut().set_loading(false);
        self.as_mut().set_error_message(QString::from(msg));
        self.as_mut().searchError(QString::from(msg));
    }

    fn search_wallhaven(mut self: Pin<&mut Self>, query: &QString) {
        let query_str = query.to_string();
        let mut categories = self.as_mut().categories().to_string();
        let mut purity = self.as_mut().purity().to_string();
        let mut sorting = self.as_mut().sorting().to_string();
        let mut atleast = self.as_mut().atleast().to_string();
        if categories.is_empty() { categories = "111".to_string(); }
        if purity.is_empty() { purity = "100".to_string(); }
        if sorting.is_empty() { sorting = "relevance".to_string(); }
        if atleast.is_empty() { atleast = "1920x1080".to_string(); }

        let client = reqwest::blocking::Client::new();
        let result = client.get("https://wallhaven.cc/api/v1/search")
            .query(&[
                ("q", query_str.as_str()),
                ("categories", categories.as_str()),
                ("purity", purity.as_str()),
                ("sorting", sorting.as_str()),
                ("atleast", atleast.as_str()),
            ])
            .send();
        match result {
            Ok(resp) => {
                if !resp.status().is_success() {
                    self.as_mut().emit_search_error(&format!("Wallhaven API: {}", resp.status()));
                    return;
                }
                match resp.json::<WallhavenResponse>() {
                    Ok(wh) => {
                        let v: Vec<WallpaperResult> = wh.data.into_iter().map(|w| {
                            let res = if w.resolution.is_empty() { "Unknown".into() } else { w.resolution };
                            WallpaperResult { preview: w.thumbs.large, full: w.full, author: res, page: w.page }
                        }).collect();
                        let json = serde_json::to_string(&v).unwrap_or_default();
                        self.as_mut().set_results_json(QString::from(&json));
                        self.as_mut().set_loading(false);
                        self.as_mut().searchCompleted();
                    }
                    Err(e) => self.as_mut().emit_search_error(&format!("Ошибка парсинга: {}", e)),
                }
            }
            Err(e) => self.as_mut().emit_search_error(&format!("Сетевая ошибка: {}", e)),
        }
    }

    fn search_unsplash(mut self: Pin<&mut Self>, query: &QString) {
        let query_str = query.to_string();
        let key = self.as_mut().unsplash_key().to_string();
        if key.is_empty() {
            self.as_mut().emit_search_error("Укажите API ключ Unsplash в настройках");
            return;
        }
        let client = reqwest::blocking::Client::new();
        let result = client.get("https://api.unsplash.com/search/photos")
            .query(&[
                ("query", query_str.as_str()),
                ("per_page", "30"),
                ("client_id", key.as_str()),
            ])
            .send();
        match result {
            Ok(resp) => {
                if !resp.status().is_success() {
                    self.as_mut().emit_search_error(&format!("Unsplash API: {}", resp.status()));
                    return;
                }
                match resp.json::<UnsplashResponse>() {
                    Ok(data) => {
                        let v: Vec<WallpaperResult> = data.results.into_iter().map(|w| {
                            WallpaperResult { preview: w.urls.small, full: w.urls.full, author: w.user.name, page: w.links.page }
                        }).collect();
                        let json = serde_json::to_string(&v).unwrap_or_default();
                        self.as_mut().set_results_json(QString::from(&json));
                        self.as_mut().set_loading(false);
                        self.as_mut().searchCompleted();
                    }
                    Err(e) => self.as_mut().emit_search_error(&format!("Ошибка парсинга Unsplash: {}", e)),
                }
            }
            Err(e) => self.as_mut().emit_search_error(&format!("Сетевая ошибка: {}", e)),
        }
    }

    pub fn add_favorite(self: Pin<&mut Self>, preview: &QString, full: &QString, author: &QString, page: &QString) {
        let mut favs = load_favorites();
        let full_str = full.to_string();
        if favs.iter().any(|f| f.full == full_str) { return; }
        favs.push(WallpaperResult {
            preview: preview.to_string(), full: full_str,
            author: author.to_string(), page: page.to_string(),
        });
        save_favorites(&favs);
        self.refresh_favorites();
    }

    pub fn remove_favorite(self: Pin<&mut Self>, full: &QString) {
        let mut favs = load_favorites();
        let target = full.to_string();
        favs.retain(|f| f.full != target);
        save_favorites(&favs);
        self.refresh_favorites();
    }

    fn refresh_favorites(mut self: Pin<&mut Self>) {
        let path = config_dir().join("favorites.json");
        let json = fs::read_to_string(&path).unwrap_or_default();
        self.as_mut().set_favorites_json(QString::from(&json));
        self.as_mut().favoritesChanged();
    }
}

fn load_favorites() -> Vec<WallpaperResult> {
    let path = config_dir().join("favorites.json");
    if !path.exists() { return Vec::new(); }
    fs::read_to_string(&path).ok().and_then(|c| serde_json::from_str(&c).ok()).unwrap_or_default()
}

fn save_favorites(favs: &[WallpaperResult]) {
    let dir = config_dir();
    let _ = fs::create_dir_all(&dir);
    if let Ok(json) = serde_json::to_string(favs) {
        let _ = fs::write(dir.join("favorites.json"), &json);
    }
}

// Helpers

fn download_image(url: &str) -> Result<Vec<u8>, String> {
    let client = reqwest::blocking::Client::new();
    let resp = client.get(url).send().map_err(|e| format!("Сетевая ошибка: {}", e))?;
    let bytes = resp.bytes().map_err(|e| format!("Ошибка скачивания: {}", e))?;
    Ok(bytes.to_vec())
}

fn write_file(path: &PathBuf, data: &[u8]) -> Result<(), String> {
    fs::write(path, data).map_err(|e| format!("Ошибка записи файла: {}", e))
}

fn save_dir() -> PathBuf {
    let home = std::env::var("HOME").or_else(|_| std::env::var("USERPROFILE")).unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(home).join("Pictures").join("Wallpapers")
}

fn config_dir() -> PathBuf {
    let home = std::env::var("HOME").or_else(|_| std::env::var("USERPROFILE")).unwrap_or_else(|_| "/tmp".into());
    PathBuf::from(home).join(".config").join("wallpapersearcher")
}

fn set_wallpaper(path: &PathBuf) -> Result<(), String> {
    let path_str = path.to_string_lossy().to_string();
    let uri = format!("file://{}", path_str);
    let desktop = std::env::var("XDG_CURRENT_DESKTOP").unwrap_or_default().to_lowercase();
    if desktop.contains("gnome") || desktop.contains("unity") {
        run_cmd("gsettings", &["set", "org.gnome.desktop.background", "picture-uri", &uri])?;
        let _ = run_cmd("gsettings", &["set", "org.gnome.desktop.background", "picture-uri-dark", &uri]);
        return Ok(());
    }
    if desktop.contains("kde") || desktop.contains("plasma") { return run_cmd("plasma-apply-wallpaperimage", &[&path_str]); }
    if desktop.contains("xfce") {
        let output = run_cmd_output("xfconf-query", &["-c", "xfce4-desktop", "-l"]).unwrap_or_default();
        for line in output.lines() { let t = line.trim(); if t.contains("last-image") || t.contains("image-path") { let _ = run_cmd("xfconf-query", &["-c", "xfce4-desktop", "-p", t, "-s", &path_str]); } }
        return Ok(());
    }
    if desktop.contains("cinnamon") { return run_cmd("gsettings", &["set", "org.cinnamon.desktop.background", "picture-uri", &uri]); }
    if desktop.contains("mate") { return run_cmd("gsettings", &["set", "org.mate.background", "picture-filename", &path_str]); }
    if desktop.contains("budgie") { return run_cmd("gsettings", &["set", "org.gnome.desktop.background", "picture-uri", &uri]); }
    if desktop.contains("deepin") { return run_cmd("gsettings", &["set", "com.deepin.wrap.gnome.desktop.background", "picture-uri", &uri]); }
    if desktop.contains("lxqt") || desktop.contains("lxde") { return run_cmd("pcmanfm", &["--set-wallpaper", &path_str]); }
    if desktop.contains("sway") { return run_cmd("swaybg", &["-i", &path_str, "-m", "fill"]); }
    if desktop.contains("hyprland") { return run_cmd("hyprctl", &["hyprpaper", "wallpaper", ",", &path_str]); }
    run_cmd("feh", &["--bg-scale", &path_str])
        .or_else(|_| run_cmd("nitrogen", &["--set-scaled", &path_str]))
        .or_else(|_| run_cmd("gsettings", &["set", "org.gnome.desktop.background", "picture-uri", &uri]))
        .map_err(|_| "Не удалось установить обои. Установите feh или nitrogen для X11.".to_string())
}

fn run_cmd(cmd: &str, args: &[&str]) -> Result<(), String> {
    let output = Command::new(cmd).args(args).output().map_err(|e| format!("Не удалось запустить {}: {}", cmd, e))?;
    if output.status.success() { Ok(()) } else { Err(format!("{}: {}", cmd, String::from_utf8_lossy(&output.stderr))) }
}

fn run_cmd_output(cmd: &str, args: &[&str]) -> Result<String, String> {
    let output = Command::new(cmd).args(args).output().map_err(|e| format!("Не удалось запустить {}: {}", cmd, e))?;
    if output.status.success() { Ok(String::from_utf8_lossy(&output.stdout).to_string()) } else { Err(format!("{}: {}", cmd, String::from_utf8_lossy(&output.stderr))) }
}

fn crop_image(path: &PathBuf, target_w: u32, target_h: u32) -> Result<(), String> {
    let img = image::open(path).map_err(|e| format!("Не удалось открыть изображение: {}", e))?;
    let (w, h) = img.dimensions();
    let target_ratio = target_w as f64 / target_h as f64;
    let source_ratio = w as f64 / h as f64;
    let (crop_w, crop_h) = if source_ratio > target_ratio {
        ( (h as f64 * target_ratio) as u32, h)
    } else {
        (w, (w as f64 / target_ratio) as u32)
    };
    let cropped = img.crop_imm((w - crop_w) / 2, (h - crop_h) / 2, crop_w.min(w), crop_h.min(h));
    let resized = cropped.resize_exact(target_w, target_h, image::imageops::FilterType::Lanczos3);
    resized.save(path).map_err(|e| format!("Ошибка сохранения: {}", e))?;
    Ok(())
}
