import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

RowLayout {
    id: root

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    property alias text: searchField.text
    property bool loading: false
    property bool big: false
    property string language: "ru"
    signal searchRequested(string query)
    signal settingsRequested()

    Lang { id: lang; lng: root.language }

    spacing: big ? 12 : 8

    TextField {
        id: searchField
        Layout.fillWidth: true
        implicitHeight: root.big ? 52 : 36
        placeholderText: lang.t("search_placeholder")
        font.pixelSize: root.big ? 20 : 16
        font.bold: root.big

        onAccepted: {
            if (text.trim().length > 0)
                root.searchRequested(text.trim())
        }

        background: Rectangle {
            radius: root.big ? 12 : 8
            color: sysPalette.base
            border.color: searchField.activeFocus ? sysPalette.highlight : sysPalette.mid
            border.width: root.big && searchField.activeFocus ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }
        color: sysPalette.text
        leftPadding: root.big ? 20 : 12
    }

    Button {
        id: searchButton
        text: lang.t("search")
        font.pixelSize: root.big ? 18 : 16
        implicitHeight: root.big ? 52 : 36
        enabled: !root.loading && searchField.text.trim().length > 0

        onClicked: root.searchRequested(searchField.text.trim())

        background: Rectangle {
            radius: root.big ? 12 : 8
            color: searchButton.enabled ? sysPalette.highlight : sysPalette.mid
            opacity: searchButton.pressed ? 0.7 : 1.0
        }
        contentItem: Text {
            text: searchButton.text
            color: sysPalette.highlightedText
            font.pixelSize: root.big ? 18 : 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Button {
        text: "⚙"
        font.pixelSize: root.big ? 22 : 18
        implicitWidth: root.big ? 52 : 40
        implicitHeight: root.big ? 52 : 36

        onClicked: root.settingsRequested()

        background: Rectangle {
            radius: root.big ? 12 : 8
            color: parent.pressed ? sysPalette.highlight : sysPalette.button
        }
        contentItem: Text {
            text: parent.text
            color: sysPalette.buttonText
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
