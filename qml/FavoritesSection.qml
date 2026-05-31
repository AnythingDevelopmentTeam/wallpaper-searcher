import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

ColumnLayout {
    id: root

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    property string language: "ru"
    property var favorites: []
    signal previewRequested(string fullUrl, string pageUrl)
    signal removeRequested(string fullUrl)

    Lang { id: lang; lng: root.language }

    spacing: 6

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: lang.t("favorites")
            font.pixelSize: 14
            font.bold: true
            color: sysPalette.windowText
        }

        Label {
            text: "(" + root.favorites.length + ")"
            font.pixelSize: 12
            color: sysPalette.mid
        }
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        orientation: ListView.Horizontal
        spacing: 8
        clip: true

        model: root.favorites
        visible: root.favorites.length > 0

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 250 }
        }

        delegate: Rectangle {
            width: 160
            height: 100
            radius: 6
            color: sysPalette.alternateBase
            clip: true

            Image {
                anchors.fill: parent
                source: modelData.preview
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.previewRequested(modelData.full, modelData.page)
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 4
                width: 20; height: 20; radius: 10
                color: "#d00000"
                Behavior on color { ColorAnimation { duration: 100 } }

                Label {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 10
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.removeRequested(modelData.full)
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 22
                color: "#000000b0"

                Label {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    text: modelData.author || "Unknown"
                    color: "white"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        ScrollBar.horizontal: ScrollBar { active: true }
    }
}
