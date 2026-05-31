import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

Popup {
    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }
    id: root

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay
    width: 360
    height: 300

    property QtObject searcher: null
    property string language: "ru"

    Lang { id: lang; lng: root.language }

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

        Item { Layout.preferredHeight: 8 }

        Label {
            text: "Wallpaper Searcher"
            font.pixelSize: 22
            font.bold: true
            color: sysPalette.windowText
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: searcher ? searcher.version : ""
            font.pixelSize: 14
            color: sysPalette.mid
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            text: searcher && searcher.codename ? searcher.codename : ""
            font.pixelSize: 12
            color: sysPalette.mid
            Layout.alignment: Qt.AlignHCenter
            visible: text.length > 0
        }

        Label {
            text: lang.t("desc")
            font.pixelSize: 13
            color: sysPalette.windowText
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: "Rust + Qt 6 (QML) + cxx-qt"
            font.pixelSize: 11
            color: sysPalette.mid
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillHeight: true }

        Button {
            text: lang.t("close")
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
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

        Item { Layout.preferredHeight: 8 }
    }
}
