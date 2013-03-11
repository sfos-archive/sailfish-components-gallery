import QtQuick 1.1
import Sailfish.Silica 1.0

ThumbnailImage {
    property alias duration: durationLabel.text
    property alias title: titleLabel.text

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: parent.height / 2
        opacity: 0.8
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: theme.highlightDimmerColor }
        }
    }

    Label {
        id: durationLabel

        font {
            pixelSize: theme.fontSizeSmall
        }
        anchors {
            bottom: titleLabel.top; left: parent.left; leftMargin: theme.paddingMedium
        }
    }

    Label {
        id: titleLabel

        font {
            pixelSize: theme.fontSizeExtraSmall
        }
        color: theme.highlightColor
        truncationMode: TruncationMode.Elide
        anchors {
            bottom: parent.bottom; bottomMargin: theme.paddingMedium
            left: parent.left; leftMargin: theme.paddingMedium
            right: parent.right
        }
    }
}
