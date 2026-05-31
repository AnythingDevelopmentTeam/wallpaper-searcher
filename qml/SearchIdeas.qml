import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import com.wallpapersearcher

Flow {
    id: root

    SystemPalette { id: sysPalette; colorGroup: SystemPalette.Active }

    property string language: "ru"
    property var ideas: []
    signal ideaClicked(string text)

    Lang { id: lang; lng: root.language }

    spacing: 6

    Repeater {
        model: root.ideas
        delegate: Rectangle {
            height: 30
            width: ideaLabel.implicitWidth + 16
            radius: 15
            color: ideaMouse.containsMouse ? sysPalette.highlight : sysPalette.button
            Behavior on color { ColorAnimation { duration: 120 } }
            opacity: ideaMouse.containsMouse ? 0.9 : 0.7
            Behavior on opacity { NumberAnimation { duration: 120 } }

            property string ideaText: modelData

            Label {
                id: ideaLabel
                anchors.centerIn: parent
                text: modelData
                color: sysPalette.buttonText
                font.pixelSize: 12
            }

            MouseArea {
                id: ideaMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.ideaClicked(root.ideas[index])
                }
            }
        }
    }

    onLanguageChanged: {
        root.ideas = lang.seasonIdeas()
    }

    Component.onCompleted: {
        root.ideas = lang.seasonIdeas()
    }
}
