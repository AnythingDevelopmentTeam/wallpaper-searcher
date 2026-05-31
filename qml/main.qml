import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import com.wallpapersearcher

Window {
    id: root

    visible: true
    title: "Wallpaper Searcher"
    width: 960
    height: 680
    minimumWidth: 480
    minimumHeight: 400

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    color: sysPalette.window

    Lang { id: lang; lng: searcher.language }

    WallpaperSearch {
        id: searcher

        onSearchCompleted: {
            wallpaperModel.clear()
            const json = searcher.results_json
            if (!json) return
            try {
                const arr = JSON.parse(json)
                for (let i = 0; i < arr.length; i++)
                    wallpaperModel.append(arr[i])
            } catch (e) { console.warn("JSON parse error:", e) }
        }

        onSearchError: function (msg) { errorLabel.text = msg; errorLabel.visible = true }

        onSaveCompleted: function (path) {
            saveNotification.text = lang.t("saved") + ": " + path
            saveNotification.color = sysPalette.highlight
            saveNotification.visible = true; saveTimer.restart()
        }
        onSaveError: function (msg) {
            saveNotification.text = lang.t("toast_error") + ": " + msg; saveNotification.color = "#f38ba8"
            saveNotification.visible = true; saveTimer.restart()
        }
        onApplyCompleted: function (path) {
            saveNotification.text = lang.t("applied") + ": " + path
            saveNotification.color = sysPalette.highlight
            saveNotification.visible = true; saveTimer.restart()
        }
        onApplyError: function (msg) {
            saveNotification.text = lang.t("toast_error") + ": " + msg; saveNotification.color = "#f38ba8"
            saveNotification.visible = true; saveTimer.restart()
        }
        onFavoritesChanged: { favoritesModel.clear(); loadFavorites() }
    }

    property bool showPreview: false

    ListModel { id: wallpaperModel }
    ListModel { id: favoritesModel }

    function loadFavorites() {
        favoritesModel.clear()
        try {
            const arr = JSON.parse(searcher.favorites_json || "[]")
            for (let i = 0; i < arr.length; i++)
                favoritesModel.append(arr[i])
        } catch (e) {}
    }

    function isFavorite(fullUrl) {
        for (let i = 0; i < favoritesModel.count; i++) {
            if (favoritesModel.get(i).full === fullUrl) return true
        }
        return false
    }

    Component.onCompleted: loadFavorites()

    SettingsDialog { id: settingsDialog; searcher: searcher }
    AboutDialog { id: aboutDialog; language: searcher.language }

    // Empty state
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.65, 640)
        spacing: 12
        visible: wallpaperModel.count === 0 && !searcher.loading && !errorLabel.visible

        Label {
            text: lang.t("search_title")
            font.pixelSize: 36; font.bold: true
            color: sysPalette.windowText
            Layout.alignment: Qt.AlignHCenter
        }

        SearchBar {
            Layout.fillWidth: true; Layout.topMargin: 4
            loading: searcher.loading; big: true; language: searcher.language
            onSearchRequested: function(q) { errorLabel.visible = false; searcher.search(q) }
            onSettingsRequested: settingsDialog.open()
        }

        SearchIdeas {
            Layout.fillWidth: true
            Layout.topMargin: 4
            language: searcher.language
            onIdeaClicked: function(text) {
                errorLabel.visible = false
                searcher.search(text)
            }
        }
    }

    // Results state
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8
        visible: wallpaperModel.count > 0 || searcher.loading || errorLabel.visible

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: lang.t("search_title")
                font.pixelSize: 20; font.bold: true
                color: sysPalette.windowText
            }

            Item { Layout.fillWidth: true }

            Button {
                text: lang.t("about")
                font.pixelSize: 12; flat: true
                onClicked: aboutDialog.open()
                contentItem: Text { text: parent.text; color: sysPalette.mid; font.pixelSize: 12 }
                background: Item {}
            }
        }

        SearchBar {
            Layout.fillWidth: true
            loading: searcher.loading; language: searcher.language
            onSearchRequested: function(q) { errorLabel.visible = false; searcher.search(q) }
            onSettingsRequested: settingsDialog.open()
        }

        // Favorites
        FavoritesSection {
            Layout.fillWidth: true
            language: searcher.language
            favorites: {
                var arr = []
                for (var i = 0; i < favoritesModel.count; i++)
                    arr.push(favoritesModel.get(i))
                return arr
            }
            onPreviewRequested: function(fullUrl, pageUrl) {
                fullPreview.fullUrl = fullUrl
                fullPreview.pageUrl = pageUrl
                fullPreview.author = ""
                fullPreview.isFavorite = isFavorite(fullUrl)
                showPreview = true
            }
            onRemoveRequested: function(fullUrl) {
                searcher.remove_favorite(fullUrl)
            }
        }

        BusyIndicator {
            id: spinner
            Layout.alignment: Qt.AlignHCenter
            visible: searcher.loading; running: visible
            contentItem: Item {
                implicitWidth: 48; implicitHeight: 48
                Rectangle {
                    width: parent.width; height: parent.height; radius: width / 2
                    color: "transparent"
                    border.color: sysPalette.highlight; border.width: 4
                    NumberAnimation on rotation { from: 0; to: 360; duration: 1000; loops: Animation.Infinite }
                }
            }
        }

        Label {
            id: errorLabel
            Layout.fillWidth: true; wrapMode: Text.WordWrap
            color: "#f38ba8"; font.pixelSize: 14; visible: false
        }

        Label {
            id: saveNotification
            Layout.fillWidth: true; wrapMode: Text.WordWrap
            font.pixelSize: 14; visible: false
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Timer { id: saveTimer; interval: 4000; onTriggered: saveNotification.visible = false }
        }

        GridView {
            id: grid
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true

            model: wallpaperModel
            cellWidth: width / 4; cellHeight: cellWidth * 0.8
            visible: wallpaperModel.count > 0

            add: Transition {
                NumberAnimation { properties: "opacity"; from: 0; to: 1.0; duration: 300 }
            }

            delegate: Item {
                width: grid.cellWidth; height: grid.cellHeight; clip: true

                Image {
                    id: thumb
                    anchors.fill: parent; anchors.margins: 4
                    source: model.preview; asynchronous: true; fillMode: Image.PreserveAspectCrop
                }

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    color: sysPalette.alternateBase
                    visible: thumb.status === Image.Loading
                    BusyIndicator { anchors.centerIn: parent; width: 24; height: 24; running: true }
                }

                Rectangle {
                    anchors.fill: parent; anchors.margins: 4
                    color: sysPalette.mid
                    visible: thumb.status === Image.Error
                    Label { anchors.centerIn: parent; text: "⚠"; font.pixelSize: 20; color: "#f38ba8" }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent; anchors.margins: 4
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor

                    Rectangle {
                        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                        height: 28; color: "#000000b0"; visible: mouseArea.containsMouse
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Label {
                            anchors.fill: parent; anchors.leftMargin: 6
                            text: model.author || "Unknown"
                            color: sysPalette.highlightedText; font.pixelSize: 12
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Row {
                        anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 8
                        spacing: 4; visible: mouseArea.containsMouse
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        Rectangle {
                            width: 28; height: 28; radius: 4
                            color: btnFav.pressed ? sysPalette.highlight : "#000000b0"
                            Label { anchors.centerIn: parent; text: "♥"; font.pixelSize: 12; color: isFavorite(model.full) ? "#ff4444" : "white" }
                            MouseArea {
                                id: btnFav; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mouse.accepted = true
                                    if (isFavorite(model.full))
                                        searcher.remove_favorite(model.full)
                                    else
                                        searcher.add_favorite(model.preview, model.full, model.author, model.page)
                                }
                            }
                        }

                        Rectangle {
                            width: 28; height: 28; radius: 4
                            color: btnSave.pressed ? sysPalette.highlight : "#000000b0"
                            Label { anchors.centerIn: parent; text: "💾"; font.pixelSize: 12 }
                            MouseArea {
                                id: btnSave; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { mouse.accepted = true; if (model.full) searcher.save_image(model.full) }
                            }
                        }

                        Rectangle {
                            width: 28; height: 28; radius: 4
                            color: btnApply.pressed ? sysPalette.highlight : "#000000b0"
                            Label { anchors.centerIn: parent; text: "🖥"; font.pixelSize: 12 }
                            MouseArea {
                                id: btnApply; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    mouse.accepted = true
                                    if (model.full)
                                        searcher.apply_wallpaper(model.full, root.screen.width, root.screen.height)
                                }
                            }
                        }
                    }

                    onClicked: {
                        mouse.accepted = true
                        fullPreview.fullUrl = model.full
                        fullPreview.pageUrl = model.page
                        fullPreview.author = model.author
                        fullPreview.isFavorite = isFavorite(model.full)
                        showPreview = true
                    }
                }
            }

            ScrollBar.vertical: ScrollBar { active: true }
        }
    }

    // Full page preview (last for z-order)
    FullPreview {
        id: fullPreview
        anchors.fill: parent
        language: searcher.language
        opacity: showPreview ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        onBackRequested: showPreview = false
        onSaveRequested: function(url) { searcher.save_image(url) }
        onApplyRequested: function(url) {
            searcher.apply_wallpaper(url, root.screen.width, root.screen.height)
        }
        onAddFavRequested: function(preview, full, author, page) {
            searcher.add_favorite(preview, full, author, page)
        }
        onRemoveFavRequested: function(full) {
            searcher.remove_favorite(full)
        }
    }
}
