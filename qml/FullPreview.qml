import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

Item {
    id: root

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    property string language: "ru"
    property string fullUrl: ""
    property string pageUrl: ""
    property string author: ""
    property bool isFavorite: false

    signal backRequested()
    signal saveRequested(string url)
    signal applyRequested(string url)
    signal addFavRequested(string preview, string full, string author, string page)
    signal removeFavRequested(string full)

    Lang { id: lang; lng: root.language }

    focus: true
    Keys.onEscapePressed: root.backRequested()

    Rectangle {
        anchors.fill: parent
        color: sysPalette.window
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "←"
                font.pixelSize: 22
                flat: true
                implicitWidth: 44; implicitHeight: 44
                onClicked: root.backRequested()
                contentItem: Text {
                    text: parent.text; color: sysPalette.windowText
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 8; color: parent.pressed ? sysPalette.highlight : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
            }

            Label {
                text: root.author || ""
                font.pixelSize: 15
                color: sysPalette.mid
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 8
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "♥"
                font.pixelSize: 22
                flat: true
                implicitWidth: 44; implicitHeight: 44
                onClicked: {
                    if (root.isFavorite)
                        root.removeFavRequested(root.fullUrl)
                    else
                        root.addFavRequested(root.fullUrl, root.fullUrl, root.author, root.pageUrl)
                    root.isFavorite = !root.isFavorite
                }
                contentItem: Text {
                    text: parent.text
                    color: root.isFavorite ? "#ff4444" : sysPalette.mid
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: 8; color: parent.pressed ? sysPalette.highlight : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
            }
        }

        // Image
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Rectangle {
                anchors.fill: parent
                color: sysPalette.base
                radius: 12
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: root.fullUrl
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true

                    Rectangle {
                        anchors.fill: parent
                        color: sysPalette.base
                        visible: parent.status === Image.Loading
                        BusyIndicator { anchors.centerIn: parent; running: true }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: sysPalette.base
                        visible: parent.status === Image.Error
                        Label {
                            anchors.centerIn: parent
                            text: lang.t("loading_failed")
                            color: sysPalette.windowText
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }

        // Actions
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            Item { Layout.fillWidth: true }

            Button {
                text: lang.t("apply")
                font.pixelSize: 16
                implicitHeight: 48
                implicitWidth: 160
                onClicked: {
                    root.applyRequested(root.fullUrl)
                    root.backRequested()
                }
                background: Rectangle {
                    radius: 10
                    color: parent.pressed ? sysPalette.highlight : sysPalette.button
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: parent.text; color: sysPalette.buttonText
                    font.pixelSize: 16; font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: lang.t("save")
                font.pixelSize: 16
                implicitHeight: 48
                implicitWidth: 160
                onClicked: root.saveRequested(root.fullUrl)
                background: Rectangle {
                    radius: 10
                    color: parent.pressed ? sysPalette.highlight : sysPalette.button
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: parent.text; color: sysPalette.buttonText
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                text: lang.t("on_site")
                font.pixelSize: 16
                implicitHeight: 48
                implicitWidth: 160
                onClicked: { if (root.pageUrl) Qt.openUrlExternally(root.pageUrl) }
                background: Rectangle {
                    radius: 10
                    color: parent.pressed ? sysPalette.highlight : sysPalette.button
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: parent.text; color: sysPalette.buttonText
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
