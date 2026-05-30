import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

// URI должен совпадать с QmlModule::new("com.wallpapersearcher") в build.rs
import com.wallpapersearcher

/// Главное окно приложения Wallpaper Searcher.
///
/// Компоновка:
///   ┌─────────────────────────────────────┐
///   │  🖼 Wallpaper Searcher              │
///   │  [Поиск…]                 [🔍 Искать] │
///   ├─────────────────────────────────────┤
///   │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │
///   │  │ img │ │ img │ │ img │ │ img │  │
///   │  └─────┘ └─────┘ └─────┘ └─────┘  │
///   │  ┌─────┐ ┌─────┐                  │
///   │  │ img │ │ img │                  │
///   │  └─────┘ └─────┘                  │
///   └─────────────────────────────────────┘
Window {
    id: root

    visible: true
    title: "Wallpaper Searcher"
    width: 960
    height: 680
    minimumWidth: 480
    minimumHeight: 400

    // Тёмная тема (Catppuccin Mocha palette)
    color: "#1e1e2e"

    // ── Rust QObject (автоматически зарегистрирован через #[qml_element]) ──
    WallpaperSearch {
        id: searcher

        // Когда поиск завершён → парсим results_json и наполняем модель
        onSearchCompleted: {
            wallpaperModel.clear()
            const json = searcher.results_json
            if (!json) return

            try {
                const arr = JSON.parse(json)
                for (let i = 0; i < arr.length; i++) {
                    wallpaperModel.append(arr[i])
                }
            } catch (e) {
                console.warn("JSON parse error:", e)
            }
        }

        // Сигнал ошибки → показываем в UI
        onSearchError: function (msg) {
            errorLabel.text = "⚠ " + msg
            errorLabel.visible = true
        }

        // Сохранение завершено
        onSaveCompleted: function (path) {
            saveNotification.text = "💾 Сохранено: " + path
            saveNotification.color = "#a6e3a1"
            saveNotification.visible = true
            saveTimer.restart()
        }

        onSaveError: function (msg) {
            saveNotification.text = "⚠ " + msg
            saveNotification.color = "#f38ba8"
            saveNotification.visible = true
            saveTimer.restart()
        }
    }

    // ── Модель для GridView ─────────────────────────────────────
    ListModel {
        id: wallpaperModel
    }

    // ── Интерфейс ───────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ── Заголовок ───────────────────────────────────────────
        Label {
            text: "🖼 Wallpaper Searcher"
            font.pixelSize: 22
            font.bold: true
            color: "#cdd6f4"
            Layout.alignment: Qt.AlignHCenter
        }

        // ── Строка поиска ───────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Например: mountains, forest, minimal …"
                font.pixelSize: 16

                // Enter = поиск
                onAccepted: searchButton.clicked()

                background: Rectangle {
                    radius: 8
                    color: "#313244"
                    border.color: searchField.activeFocus ? "#89b4fa" : "#45475a"
                    border.width: 1
                }
                color: "#cdd6f4"
                leftPadding: 12
            }

            Button {
                id: searchButton
                text: "🔍 Искать"
                font.pixelSize: 16
                enabled: !searcher.loading && searchField.text.trim().length > 0

                onClicked: {
                    errorLabel.visible = false
                    searcher.search(searchField.text.trim())
                }

                background: Rectangle {
                    radius: 8
                    color: searchButton.enabled ? "#89b4fa" : "#45475a"
                    opacity: searchButton.pressed ? 0.7 : 1.0
                }
                contentItem: Text {
                    text: searchButton.text
                    color: "#1e1e2e"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // ── Индикатор загрузки ──────────────────────────────────
        BusyIndicator {
            id: spinner
            Layout.alignment: Qt.AlignHCenter
            visible: searcher.loading
            running: visible

            contentItem: Item {
                implicitWidth: 48
                implicitHeight: 48

                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    color: "transparent"
                    border.color: "#89b4fa"
                    border.width: 4

                    NumberAnimation on rotation {
                        from: 0; to: 360
                        duration: 1000
                        loops: Animation.Infinite
                    }
                }
            }
        }

        // ── Сообщение об ошибке ─────────────────────────────────
        Label {
            id: errorLabel
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: "#f38ba8"
            font.pixelSize: 14
            visible: false
        }

        // ── Уведомление о сохранении ────────────────────────────
        Label {
            id: saveNotification
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: "#a6e3a1"
            font.pixelSize: 14
            visible: false

            Timer {
                id: saveTimer
                interval: 4000
                onTriggered: saveNotification.visible = false
            }
        }

        // ── Подсказка / пустое состояние ────────────────────────
        Label {
            id: emptyLabel
            Layout.alignment: Qt.AlignHCenter
            text: "Введите запрос и нажмите «Искать»"
            color: "#6c7086"
            font.pixelSize: 14
            visible: wallpaperModel.count === 0
                     && !searcher.loading
                     && !errorLabel.visible
        }

        // ── Сетка результатов ───────────────────────────────────
        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: wallpaperModel
            cellWidth: width / 4          // 4 колонки
            cellHeight: cellWidth * 0.8

            visible: wallpaperModel.count > 0

            add: Transition {
                NumberAnimation {
                    properties: "opacity"
                    from: 0; to: 1.0
                    duration: 300
                }
            }

            delegate: Item {
                width: grid.cellWidth
                height: grid.cellHeight
                clip: true

                Image {
                    id: thumb
                    anchors.fill: parent
                    anchors.margins: 4
                    source: model.preview
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }

                // Плейсхолдер во время загрузки
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "#313244"
                    visible: thumb.status === Image.Loading

                    BusyIndicator {
                        anchors.centerIn: parent
                        width: 24; height: 24
                        running: true
                    }
                }

                // Ошибка загрузки картинки
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "#45475a"
                    visible: thumb.status === Image.Error

                    Label {
                        anchors.centerIn: parent
                        text: "⚠"; font.pixelSize: 20; color: "#f38ba8"
                    }
                }

                // Интерактивный слой поверх картинки
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    anchors.margins: 4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    // Подпись автора (при наведении)
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 28
                        color: "#000000b0"
                        visible: mouseArea.containsMouse

                        Label {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            text: "📷 " + (model.author || "Unknown")
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // Кнопка сохранения (при наведении)
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: saveLabel.implicitWidth + 12
                        height: 24
                        radius: 4
                        color: saveBtnArea.pressed ? "#89b4fa" : "#000000b0"
                        visible: mouseArea.containsMouse

                        Label {
                            id: saveLabel
                            anchors.centerIn: parent
                            text: "💾 Save"
                            color: "#cdd6f4"
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: saveBtnArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                mouse.accepted = true
                                if (model.full)
                                    searcher.save_image(model.full)
                            }
                        }
                    }

                    onClicked: {
                        if (model.page)
                            Qt.openUrlExternally(model.page)
                    }
                }
            }

            ScrollBar.vertical: ScrollBar { active: true }
        }
    }

    // ── Safe Search badge ───────────────────────────────────────
    Rectangle {
        x: 8
        y: parent.height - height - 6
        implicitWidth: label.implicitWidth + 12
        implicitHeight: label.implicitHeight + 8
        radius: 6
        color: "#a6e3a1"
        opacity: 0.85

        Label {
            id: label
            anchors.centerIn: parent
            text: "✓ Safe Search"
            color: "#1e1e2e"
            font.pixelSize: 11
            font.bold: true
        }
    }
}
