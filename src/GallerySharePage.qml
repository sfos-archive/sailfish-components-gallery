import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.signonuiservice 1.0

Page {
    id: page

    property alias endDestination: accountCreator.endDestination
    property alias source: shareMethodList.source
    property alias mimeType: shareMethodList.filter
    property alias content: shareMethodList.content

    ShareMethodList {
        id: shareMethodList

        height: parent.height
        header: PageHeader {
            //: Page header for share method selection
            //% "Share"
            title: qsTrId("components_gallery-he-share")
        }
        // Add "add account" to the footer. User must be able to
        // create accounts in a case there are none.
        footer: BackgroundItem {
            Label {
                id: addAccountLabel
                //% "Add account"
                text: qsTrId("components_gallery-la-add_account")
                x: Theme.horizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                jolla_signon_ui_service.inProcessParent = accountCreator.endDestination
                accountCreator.startAccountCreation()
            }
        }

        SignonUiService {
            id: jolla_signon_ui_service
        }

        AccountCreationManager {
            id: accountCreator
            serviceFilter: ["sharing","e-mail"]
            endDestinationAction: PageStackAction.Pop
        }
    }
}
