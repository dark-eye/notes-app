/*
 * Copyright: 2013 - 2014 Canonical, Ltd
 *
 * This file is part of reminders
 *
 * reminders is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import Ubuntu.OnlineAccounts 0.1
import Ubuntu.OnlineAccounts.Client 0.1
import Evernote 0.1

Page {
    id: root
    objectName: "Accountselectorpage"
    title: i18n.tr("Select account")

    property alias accounts: optionSelector.model
    property bool isChangingAccount
    property bool unauthorizedAccounts

    signal accountSelected(string username, var handle)

    Setup {
        id: setup
        applicationId: "com.ubuntu.reminders_reminders"
        providerId: useSandbox ? "evernote-sandbox" : "evernote"
    }

    Column {
        anchors { fill: parent; margins: units.gu(2) }
        spacing: units.gu(2)

        Button {
            anchors { left: parent.left; right: parent.right; margins: units.gu(1) }
            text: i18n.tr("Store notes locally only")
            onClicked: {
                root.accountSelected("@local", null)
            }
        }

        Label {
            anchors { left: parent.left; right: parent.right; margins: units.gu(1) }
            text: i18n.tr("Accounts on www.evernote.com")
        }

        OptionSelector {
            id: optionSelector
            width: parent.width
            expanded: true

            delegate: Standard {
                objectName: "EvernoteAccount"
                text: displayName
                showDivider: index + 1 !== accounts.count

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (model.enabled) {
                            root.accountSelected(displayName, accountServiceHandle)
                        }
                        else {
                            console.log('authorize')
                        }
                    }
                }

                Component.onCompleted: {
                    if (isChangingAccount && displayName == preferences.accountName) {
                        optionSelector.selectedIndex = index;
                    }
                    if (!model.enabled) {
                        text = i18n.tr("%1 - Tap to authorize").arg(text)
                    }
                }
            }
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - units.gu(2)
            text: i18n.tr("Add new account")
            color: UbuntuColors.orange
            onClicked: setup.exec()
        }
     }

     head.backAction: Action {
         visible: isChangingAccount
         iconName: "back"
         text: i18n.tr("Back")
         onTriggered: { pagestack.pop(); }
     }
}
