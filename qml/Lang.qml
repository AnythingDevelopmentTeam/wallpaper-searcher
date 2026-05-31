import QtQuick

QtObject {
    property string lng: "ru"

    function t(key) {
        var m = {
            "search_title": {ru:"Поиск обоев",en:"Wallpaper Search"},
            "search_placeholder": {ru:"Например: mountains, forest, minimal …",en:"e.g. mountains, forest, minimal …"},
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
            "loading_failed": {ru:"Не удалось загрузить",en:"Failed to load"},
            "version": {ru:"Версия 0.1.0",en:"Version 0.1.0"},
            "desc": {ru:"Поиск и установка обоев с Wallhaven и Unsplash\nнапрямую из приложения.",en:"Search and set wallpapers from Wallhaven and Unsplash\ndirectly from the app."},
            "source": {ru:"Источник",en:"Source"},
            "unsplash_api_key": {ru:"Unsplash API ключ",en:"Unsplash API Key"},
            "enter_access_key": {ru:"Введите Access Key…",en:"Enter Access Key…"},
            "get_key_hint": {ru:"Получить ключ: unsplash.com/developers",en:"Get key: unsplash.com/developers"},
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
        };
        var entry = m[key];
        if (!entry) return key;
        return entry[this.lng] || entry["ru"] || key;
    }

    function seasonIdeas() {
        var month = new Date().getMonth();
        if (this.lng === "en") {
            var springEn = ["sakura","cherry blossom","spring flowers","tulips","meadow","butterflies","green landscape","mountain trail","mountain stream","wildflowers","spring rain","garden","blooming trees","fresh grass","rainbow","valley","hills","river","sunrise","park","orchard","blooming forest","flower field","morning dew","may"];
            var summerEn = ["beach","ocean","tropical island","sunset","palm trees","summer sun","sea","coastline","surfing","sailing","lake","mountain lake","summer forest","camping","starry sky","thunderstorm","sunflowers","lavender field","waterfall","coral reef","tropical fish","beach umbrella","sand dunes","cliffs","island"];
            var fallEn = ["autumn leaves","fall forest","maple leaves","mountain fog","golden hour","foggy forest","harvest","pumpkin","fall road","foggy lake","red leaves","orange foliage","mist","dawn","log cabin","mountain view","acorn","fall rain","tall trees","forest trail","morning mist","fall colors","haystack","golden trees","indian summer"];
            var winterEn = ["snow mountain","winter forest","snowflake","aurora borealis","frozen lake","winter sunset","snowy trees","frost","aurora","blizzard","frozen lake","mountain peak","winter cabin","snow trail","icicles","snowstorm","white landscape","moon","winter night","penguin","snowy owl","ice castle","fog","skiing","snowboarding"];
            if (month >= 2 && month <= 4) return springEn;
            if (month >= 5 && month <= 7) return summerEn;
            if (month >= 8 && month <= 10) return fallEn;
            return winterEn;
        } else {
            var springRu = ["sakura","черри блоссом","весенние цветы","тюльпаны","луг","бабочки","зелёный пейзаж","горная тропа","горный ручей","полевые цветы","весенний дождь","сад","цветущие деревья","свежая трава","радуга","долина","холмы","река","рассвет","парк","фруктовый сад","цветущий лес","цветочное поле","утренняя роса","май"];
            var summerRu = ["пляж","океан","тропический остров","закат","пальмы","летнее солнце","море","побережье","сёрфинг","парусный спорт","озеро","горное озеро","летний лес","кемпинг","звёздное небо","гроза","подсолнухи","лавандовое поле","водопад","коралловый риф","тропические рыбы","пляжный зонт","песчаные дюны","скалы","остров"];
            var fallRu = ["осенние листья","осенний лес","кленовые листья","горный туман","золотой час","туманный лес","урожай","тыква","осенняя дорога","туманное озеро","красные листья","оранжевая листва","туман","рассвет","деревянный домик","горный вид","жёлудь","осенний дождь","высокие деревья","тропа в лесу","утренний туман","осенние краски","стог сена","золотые деревья","бабье лето"];
            var winterRu = ["снежная гора","зимний лес","снежинка","северное сияние","ледяное озеро","зимний закат","заснеженные деревья","иней","аврора","метель","замерзшее озеро","горная вершина","зимний домик","снежная тропа","сосульки","вьюга","белый пейзаж","луна","зимняя ночь","пингвин","белая сова","ледяной замок","туман","лыжи","сноуборд"];
            if (month >= 2 && month <= 4) return springRu;
            if (month >= 5 && month <= 7) return summerRu;
            if (month >= 8 && month <= 10) return fallRu;
            return winterRu;
        }
    }
}
