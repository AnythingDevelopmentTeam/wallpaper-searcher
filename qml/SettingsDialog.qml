import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

Pane {
    id: root

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    property QtObject searcher: null
    signal back()

    Lang { id: lang; lng: searcher ? searcher.language : "ru" }

    opacity: visible ? 1 : 0
    visible: false
    Behavior on opacity { NumberAnimation { duration: 200 } }

    background: Rectangle { color: sysPalette.window }

    contentItem: ColumnLayout {
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16; Layout.rightMargin: 16; Layout.topMargin: 12
            spacing: 8

            Button {
                text: "\u2190"
                font.pixelSize: 22
                flat: true
                onClicked: root.back()
                contentItem: Text { text: parent.text; color: sysPalette.windowText; font.pixelSize: 22 }
                background: Item {}
            }

            Label {
                text: lang.t("settings")
                font.pixelSize: 20; font.bold: true
                color: sysPalette.windowText
                Layout.fillWidth: true
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            leftPadding: 16; rightPadding: 16; topPadding: 8; bottomPadding: 16

            ColumnLayout {
                id: settingsColumn
                width: parent.availableWidth
                spacing: 8

                GroupBox {
                    title: lang.t("language")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4
                        ComboBox {
                            id: langCombo
                            Layout.fillWidth: true
                            model: [lang.t("russian"), lang.t("english")]
                        }
                    }
                }

                GroupBox {
                    title: lang.t("source")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4
                        ComboBox {
                            id: sourceCombo
                            Layout.fillWidth: true
                            model: ["Wallhaven", "Unsplash"]
                        }
                    }
                }

                GroupBox {
                    title: lang.t("unsplash_api_key")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4

                        TextField {
                            id: unsplashKeyField
                            Layout.fillWidth: true
                            placeholderText: lang.t("enter_access_key")
                            font.pixelSize: 14

                            background: Rectangle {
                                radius: 6
                                color: sysPalette.base
                                border.color: unsplashKeyField.activeFocus ? sysPalette.highlight : sysPalette.mid
                                border.width: 1
                                Behavior on border.color { ColorAnimation { duration: 100 } }
                            }
                            color: sysPalette.text
                            leftPadding: 8
                        }

                        Label {
                            text: lang.t("get_key_hint")
                            font.pixelSize: 10
                            color: sysPalette.mid
                        }
                    }
                }

                GroupBox {
                    title: lang.t("categories")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4
                        CheckBox { id: catGeneral; text: "General"; checked: true }
                        CheckBox { id: catAnime; text: "Anime"; checked: true }
                        CheckBox { id: catPeople; text: "People"; checked: true }
                    }
                }

                GroupBox {
                    title: lang.t("purity")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4
                        CheckBox { id: purSfw; text: "SFW"; checked: true }
                        CheckBox { id: purSketchy; text: "Sketchy" }
                        CheckBox { id: purNsfw; text: "NSFW" }
                    }
                }

                GroupBox {
                    title: lang.t("sorting")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4
                        ComboBox {
                            id: sortCombo
                            Layout.fillWidth: true
                            model: ["relevance", "date_added", "views", "favorites", "toplist", "random"]
                        }
                    }
                }

                GroupBox {
                    title: lang.t("min_resolution")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 4
                        ComboBox {
                            id: resCombo
                            Layout.fillWidth: true
                            model: [lang.t("any"), "1920x1080", "2560x1440", "3840x2160", "5120x2880"]
                            currentIndex: 1
                        }
                    }
                }

                GroupBox {
                    title: lang.t("about")
                    Layout.fillWidth: true

                    contentItem: ColumnLayout {
                        spacing: 6

                        Label {
                            text: "Wallpaper Searcher"
                            font.pixelSize: 15; font.bold: true
                            color: sysPalette.windowText
                        }

                        Label {
                            text: searcher ? searcher.version : ""
                            font.pixelSize: 12
                            color: sysPalette.mid
                        }

                        Label {
                            text: searcher && searcher.codename ? searcher.codename : ""
                            font.pixelSize: 12
                            color: sysPalette.mid
                            visible: text.length > 0
                        }

                        Label {
                            text: lang.t("desc")
                            font.pixelSize: 12
                            color: sysPalette.windowText
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Label {
                            text: "Rust + Qt 6 (QML) + cxx-qt"
                            font.pixelSize: 10
                            color: sysPalette.mid
                        }

                        Button {
                            id: updateBtn
                            text: root.checkingForUpdates ? "..." : lang.t("check_updates")
                            font.pixelSize: 13
                            enabled: !root.checkingForUpdates

                            onClicked: {
                                if (searcher) {
                                    updateResultLabel.text = ""
                                    root.checkingForUpdates = true
                                    updateBtn.enabled = false
                                    searcher.check_for_updates()
                                }
                            }

                            background: Rectangle {
                                radius: 6
                                color: updateBtn.enabled ? (updateBtn.pressed ? sysPalette.highlight : sysPalette.button) : sysPalette.mid
                            }
                            contentItem: Text {
                                text: updateBtn.text
                                color: sysPalette.buttonText
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Label {
                            id: updateResultLabel
                            font.pixelSize: 12
                            color: sysPalette.mid
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: text.length > 0
                        }
                    }
                }

                Item { Layout.preferredHeight: 8 }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    Button {
                        text: lang.t("apply_changes")
                        font.pixelSize: 14
                        onClicked: {
                            if (root.searcher) {
                                root.searcher.language = langCombo.currentIndex === 1 ? "en" : "ru"
                                root.searcher.search_source = sourceCombo.currentText === "Unsplash" ? "unsplash" : "wallhaven"
                                root.searcher.unsplash_key = unsplashKeyField.text
                                root.searcher.categories = getCategories()
                                root.searcher.purity = getPurity()
                                root.searcher.sorting = sortCombo.currentText
                                root.searcher.atleast = resCombo.currentIndex === 0 ? "" : resCombo.currentText
                            }
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.pressed ? sysPalette.highlight : sysPalette.button
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        contentItem: Text {
                            text: parent.text
                            color: sysPalette.buttonText
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: lang.t("reset")
                        font.pixelSize: 14
                        onClicked: {
                            langCombo.currentIndex = root.searcher && root.searcher.language === "en" ? 1 : 0
                            sourceCombo.currentIndex = 0
                            unsplashKeyField.text = ""
                            catGeneral.checked = true; catAnime.checked = true; catPeople.checked = true
                            purSfw.checked = true; purSketchy.checked = false; purNsfw.checked = false
                            sortCombo.currentIndex = 0
                            resCombo.currentIndex = 1
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.pressed ? sysPalette.highlight : sysPalette.button
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        contentItem: Text {
                            text: parent.text
                            color: sysPalette.buttonText
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: lang.t("cancel")
                        font.pixelSize: 14
                        onClicked: root.back()

                        background: Rectangle {
                            radius: 8
                            color: parent.pressed ? sysPalette.highlight : sysPalette.button
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        contentItem: Text {
                            text: parent.text
                            color: sysPalette.buttonText
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                Item { Layout.preferredHeight: 8 }
            }
        }
    }

    Connections {
        target: searcher
        function onUpdateAvailable(version, downloadUrl, changelog) {
            root.checkingForUpdates = false
            updateBtn.enabled = true
            updateResultLabel.text = lang.t("update_available") + " " + version
            updateResultLabel.color = sysPalette.highlight
        }
        function onUpdateCheckError(error) {
            root.checkingForUpdates = false
            updateBtn.enabled = true
            updateResultLabel.text = error
            updateResultLabel.color = "#f38ba8"
        }
    }

    property bool checkingForUpdates: false

    function getCategories() {
        return (catGeneral.checked ? "1" : "0") + (catAnime.checked ? "1" : "0") + (catPeople.checked ? "1" : "0")
    }

    function getPurity() {
        return (purSfw.checked ? "1" : "0") + (purSketchy.checked ? "1" : "0") + (purNsfw.checked ? "1" : "0")
    }

    function loadFromSearcher() {
        if (!root.searcher) return
        langCombo.currentIndex = root.searcher.language === "en" ? 1 : 0
        sourceCombo.currentIndex = root.searcher.search_source === "unsplash" ? 1 : 0
        unsplashKeyField.text = root.searcher.unsplash_key || ""

        var cats = root.searcher.categories || "111"
        catGeneral.checked = cats[0] === "1"
        catAnime.checked = cats[1] === "1"
        catPeople.checked = cats[2] === "1"

        var pur = root.searcher.purity || "100"
        purSfw.checked = pur[0] === "1"
        purSketchy.checked = pur[1] === "1"
        purNsfw.checked = pur[2] === "1"

        var sortIdx = sortCombo.find(root.searcher.sorting || "relevance")
        if (sortIdx >= 0) sortCombo.currentIndex = sortIdx

        var res = root.searcher.atleast || "1920x1080"
        var resIdx = resCombo.find(res)
        if (resIdx >= 0) resCombo.currentIndex = resIdx
        else resCombo.currentIndex = 0
    }

    onVisibleChanged: {
        if (visible) {
            opacity = 1
            loadFromSearcher()
        }
    }
}
