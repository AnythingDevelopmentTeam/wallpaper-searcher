import QtQuick

QtObject {
    property string lng: "ru"

    function t(key) {
        var m = {
            "search_title": {ru:"Поиск обоев",en:"Wallpaper Search"},
            "search_placeholder": {ru:"Куда дальше?",en:"What's next?"},
            "search": {ru:"Искать",en:"Search"},
            "about": {ru:"О программе",en:"About"},
            "settings": {ru:"Настройки",en:"Settings"},
            "favorites": {ru:"Избранное",en:"Favorites"},
            "apply": {ru:"Применить",en:"Apply"},
            "in_favorites": {ru:"✓ В избранном",en:"✓ In Favorites"},
            "add_to_favorites": {ru:"В избранное",en:"Add to Favorites"},
            "on_site": {ru:"На сайте",en:"View on Site"},
            "save": {ru:"Сохранить",en:"Save"},
            "close": {ru:"Закрыть",en:"Close"},
            "cancel": {ru:"Отмена",en:"Cancel"},
            "reset": {ru:"Сбросить",en:"Reset"},
            "saved": {ru:"Сохранено",en:"Saved"},
            "applied": {ru:"Установлены",en:"Applied"},
            "loading_failed": {ru:"Не удалось загрузить:(",en:"Failed to load:("},
            "desc": {ru:"Поиск и установка обоев.",en:"Search and set wallpapers."},
            "source": {ru:"Источник",en:"Source"},
            "unsplash_api_key": {ru:"Unsplash API Key",en:"Unsplash API Key"},
            "enter_access_key": {ru:"Введите Access Key…",en:"Enter Access Key…"},
            "get_key_hint": {ru:"Получите свой ключ: unsplash.com/developers",en:"Get your key: unsplash.com/developers"},
            "categories": {ru:"Категории",en:"Categories"},
            "purity": {ru:"Чистота",en:"Purity"},
            "sorting": {ru:"Сортировка",en:"Sorting"},
            "min_resolution": {ru:"Мин. разрешение",en:"Min. Resolution"},
            "any": {ru:"Любое",en:"Any"},
            "language": {ru:"Язык",en:"Language"},
            "russian": {ru:"Русский",en:"Russian"},
            "english": {ru:"English",en:"English"},
            "apply_changes": {ru:"Применить",en:"Apply"},
            "toast_error": {ru:"Ошибка",en:"Error"},
            "check_updates": {ru:"Проверить обновления",en:"Check for Updates"},
            "update_available": {ru:"Доступно обновление!:",en:"Update available:"},
            "update_check_error": {ru:"Ошибка проверки:",en:"Update check failed:"},
        };
        var entry = m[key];
        if (!entry) return key;
        return entry[this.lng] || entry["ru"] || key;
    }
}
