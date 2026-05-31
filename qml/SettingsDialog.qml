import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

Popup {
    id: root

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay
    width: 420
    height: 620

    property QtObject searcher: null

    Lang { id: lang; lng: searcher ? searcher.language : "ru" }

    enter: Transition {
        NumberAnimation { property: "scale"; from: 0.85; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
    }

    exit: Transition {
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }

    background: Rectangle { color: sysPalette.window; radius: 8 }

    contentItem: ColumnLayout {
        spacing: 12

        Label {
            text: lang.t("settings")
            font.pixelSize: 18
            font.bold: true
            color: sysPalette.windowText
            Layout.alignment: Qt.AlignHCenter
        }

        // Language
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

        // Source
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

        // API key
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

        // Categories
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

        // Purity
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

        // Sorting
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

        // Min resolution
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
                    root.close()
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
                onClicked: root.close()

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
    }

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

    onOpened: loadFromSearcher()
}
