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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1
//import "components"
import "ui"
import Evernote 0.1
import Ubuntu.OnlineAccounts 0.1

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {

    id: root

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.reminders"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    onWidthChanged: print("********************* width", width)

    property bool narrowMode: root.width < units.gu(80)

    onNarrowModeChanged: print("#################################", narrowMode)

    // Temporary background color. This can be changed to other suitable backgrounds when we get official mockup designs
    backgroundColor: UbuntuColors.coolGrey

    property var accountPage;

    function openAccountPage(isChangingAccount) {
        if (accountPage) {
            accountPage.destroy(100)
        }
        var component = Qt.createComponent(Qt.resolvedUrl("ui/AccountSelectorPage.qml"));
        accountPage = component.createObject(root, {accounts: accounts, isChangingAccount: isChangingAccount});
        accountPage.accountSelected.connect(function(handle) { accountService.objectHandle = handle; pagestack.pop(); });
        pagestack.push(accountPage);
    }

    function displayNote(note) {
        if (root.narrowMode) {
            var component = Qt.createComponent(Qt.resolvedUrl("ui/NotePage.qml"));
            var page = component.createObject();
            page.editNote.connect(function(note) {root.switchToEditMode(note)})
            pagestack.push(page, {note: note})
        } else {
            var view = sideViewLoader.embed(Qt.resolvedUrl("ui/NoteView.qml"))
            view.note = note;
        }
    }

    function switchToEditMode(note) {
        if (root.narrowMode) {
            pagestack.pop();
            var component = Qt.createComponent(Qt.resolvedUrl("ui/EditNotePage.qml"));
            var page = component.createObject();
            page.exitEditMode.connect(function() {pagestack.pop()});
            pagestack.push(page, {note: note});
        } else {
            sideViewLoader.clear();
            var view = sideViewLoader.embed(Qt.resolvedUrl("ui/EditNoteView.qml"))
            print("--- setting note:", note)
            view.note = note;
            view.exitEditMode.connect(function(note) {print("**** note", note); root.displayNote(note)});
        }
    }

    AccountServiceModel {
        id: accounts
        service: "evernote"
    }

    AccountService {
        id: accountService
        onObjectHandleChanged: authenticate(null);
        onAuthenticated: {
            if (EvernoteConnection.token && EvernoteConnection.token != reply.AccessToken) {
                EvernoteConnection.clearToken();
            }
            EvernoteConnection.token = reply.AccessToken;
        }
        onAuthenticationError: {
            console.log("Authentication failed, code " + error.code)
        }
    }

    Component.onCompleted: {
        if (tablet) {
            width = units.gu(100);
            height = units.gu(75);
        } else if (phone) {
            width = units.gu(40);
            height = units.gu(75);
        }

        pagestack.push(rootTabs)
        print("got accounts:", accounts.count)
        var accountName = accountPreference.accountName;
        if (accountName) {
            var i;
            for (i = 0; i < accounts.count; i++) {
                if (accounts.get(i, "displayName") == accountName) {
                    accountService.objectHandle = accounts.get(i, "accountServiceHandle");
                }
            }
        }
        if (!accountService.objectHandle) {
            switch (accounts.count) {
            case 0:
                PopupUtils.open(noAccountDialog)
                print("No account available! Please setup an account in the system settings");
                break;
            case 1:
                accountService.objectHandle = accounts.get(0, "accountServiceHandle");
                break;
            default:
                openAccountPage(false);
            }
        }
    }

    Connections {
        target: UserStore
        onUsernameChanged: {
            print("Logged in as user:", UserStore.username);
            accountPreference.accountName = UserStore.username;
        }
    }

    Connections {
        target: NotesStore
        onNoteCreated: {
            var note = NotesStore.note(guid);
            print("note created:", note.guid);
            if (root.narrowMode) {
                var component = Qt.createComponent(Qt.resolvedUrl("ui/EditNotePage.qml"));
                var page = component.createObject();
                page.exitEditMode.connect(function() {pagestack.pop();});
                pagestack.push(page, {note: note});
            } else {
                notesPage.selectedNote = note;
                var view = sideViewLoader.embed(Qt.resolvedUrl("ui/EditNoteView.qml"));
                view.note = note;
                view.exitEditMode.connect(function(note) {root.displayNote(note)});
            }
        }
    }

    PageStack {
        id: pagestack
        anchors.rightMargin: root.narrowMode ? 0 : root.width - units.gu(40)

        Tabs {
            id: rootTabs

            anchors.fill: parent

            Tab {
                title: i18n.tr("Notes")
                page: NotesPage {
                    id: notesPage

                    onEditNote: {
                        root.switchToEditMode(note)
                    }

                    onSelectedNoteChanged: {
                        if (selectedNote !== null) {
                            root.displayNote(selectedNote);
                        } else {
                            sideViewLoader.clear();
                        }
                    }
                    onOpenSearch: {
                        var component = Qt.createComponent(Qt.resolvedUrl("ui/SearchNotesPage.qml"))
                        var page = component.createObject();
                        pagestack.push(page)
                        page.noteSelected.connect(function(note) {root.displayNote(note)})
                    }
                }
            }

            Tab {
                title: i18n.tr("Notebooks")
                page: NotebooksPage {
                    id: notebooksPage

                    onOpenNotebook: {
                        var component = Qt.createComponent(Qt.resolvedUrl("ui/NotesPage.qml"))
                        var page = component.createObject();
                        print("opening note page for notebook", notebookGuid)
                        pagestack.push(page, {title: title/*, filter: notebookGuid*/});
                        page.selectedNoteChanged.connect(function() {
                            print("foo", page.selectedNote);
                            if (page.selectedNote) {
                                root.displayNote(page.selectedNote);
                            }
                        })
                        page.editNote.connect(function(note) {
                            root.switchToEditMode(note)
                        })
                        NotesStore.refreshNotes();
                    }
                }
            }

            Tab {
                title: i18n.tr("Reminders")
                page: RemindersPage {
                    id: remindersPage
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: pagestack.width / 2
        visible: !root.narrowMode
        text: "No note selected.\nSelect a note to see it in detail."
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        fontSize: "large"
        width: parent.width - pagestack.width
    }

    Loader {
        id: sideViewLoader
        anchors { top: parent.top; right: parent.right; bottom: parent.bottom; topMargin: units.gu(10) }
        width: root.width - pagestack.width

        ThinDivider {
            width: sideViewLoader.height
            anchors { right: null; left: parent.left; }
            z: 5

            transform: Rotation {
                angle: 90
            }
        }

        function embed(view, args) {
            source = view;
            return item;
        }

        function clear() {
            source = "";
        }
    }

    Component {
        id: noAccountDialog
        Dialog {
            id: noAccount
            title: i18n.tr("No account available")
            text: i18n.tr("Please setup an account in the system settings")
            Button {
                text: i18n.tr("Open account settings")
                color: UbuntuColors.orange
                onClicked: Qt.openUrlExternally("settings:///system/online-accounts") 
            }
        }
   }
}
