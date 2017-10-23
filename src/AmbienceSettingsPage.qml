import QtQuick 2.0
import com.jolla.gallery.ambience 1.0 as Settings
import Sailfish.Ambience 1.0

Settings.AmbienceSettingsPage {
    property alias previousAmbienceUrl: previousAmbience.url

    allowRemove: previousAmbience.contentId !== 0

    // Monitor the previous ambience, if it has been removed don't allow the
    // current one to be removed as well.
    AmbienceInfo {
        id: previousAmbience
    }

    onAmbienceRemoved: {
        Ambience.source = previousAmbienceUrl
    }
}

