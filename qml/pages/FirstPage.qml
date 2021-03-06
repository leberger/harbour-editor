import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0
import io.thp.pyotherside 1.3
import harbour.editor.documenthandler 1.0
import "../components"
import "../components/pullMenus/rows"

Page {
    id: editorPage

    property int lastLineCount: 0
    property int sizeBackgroundItemMainMenuFirstRow: pullMenu2.width / 4
    property int sizeBackgroundItemMainMenu: pullMenu2.width / 5
    property int sizeBackgroundItem: hotActionsMenu.width / 5
    property string filePath: ""
    property bool saved: false

    property bool searched: false
    property bool searchRowVisible: false

    property bool highlightingEnabled: false


    Notification {
        id: outputNotifications
        category: "Editor."
    }

    BusyIndicator {
        id: busy
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: true
    }


    function setVariables(readOnly){
        myTextArea.readOnly = readOnly
    }

    function pageStatusChange(page){
        documentHandler.setStyle(propertiesHighlightColor, stringHighlightColor,
                                 qmlHighlightColor, javascriptHighlightColor,
                                 commentHighlightColor, keywordsHighlightColor,
                                 myTextArea.font.pixelSize);

        documentHandler.setDictionary(getFileType(filePath)); //enable appropriate dictionary file
        console.log(getFileType(filePath)); //Debug
    }


    function setFilePath(filePathFromChooser) { //TODO refactoring of this function (it uses ALSO HistoryPage)
        filePath = filePathFromChooser;
        pageStack.replaceAbove(null, Qt.resolvedUrl("FirstPage.qml"), {filePath: filePathFromChooser}, PageStackAction.Animated);
        pageStack.nextPage();
    }

    //TODO rewrite (delete)
    function saveAsSetFilePath(filePathFromChooser) {
        filePath = filePathFromChooser;
        pageStack.replaceAbove(null, Qt.resolvedUrl("FirstPage.qml"), {filePath: filePathFromChooser}, PageStackAction.Animated);
        pageStack.nextPage();
        if (filePath!=="") {
            //py.call('editFile.savings', [filePath,documentHandler.text], function() {}); //test it :)
            py.call('editFile.savings', [filePath,myTextArea.text], function() {
                outputNotifications.close()
                outputNotifications.previewBody = qsTr("Document saved!")
                outputNotifications.publish()
            });
        }
        py.call('editFile.openings', [filePath], function(result) {
            myTextArea.text = result;
        });
    }

    function numberOfLines() {
        var count = (myTextArea.text.match(/\n/g) || []).length;
        count += 1;
        return count;
    }

    function lineNumberChanged() {
        if (myTextArea._editor.lineCount > lastLineCount) {
            console.log("Last character = " + myTextArea.text.slice(-1));
            if(myTextArea.text.slice(-1) !== "\n") {
                lineNumbers.text += "\n"
            }
            else {
                lineNumbers.text += numberOfLines() + "\n";
            }

            lastLineCount = myTextArea._editor.lineCount;

        } else if (myTextArea._editor.lineCount < lastLineCount) {
            lineNumbers.text = lineNumbers.text.slice(0, -2);
            lastLineCount = myTextArea._editor.lineCount;
        }
    }

    //for syntax highlighting
    function getFileType(text) {
        return text.substr(text.lastIndexOf('.') + 1 )
    }

    //Function for cover
    function getName(text) {
        return text.substr(text.lastIndexOf('/') + 1 );
    }
    //Function for cover
    function wordsCounter(text) {
        try {
            return text.match(/\S+/g).length
        }
        catch (ex) {
            return 0
        }
    }


    Rectangle {
        id: background
        color: bgColor
        anchors.fill: parent
        visible: true

        SilicaFlickable {
            id: view
            anchors.fill: parent

            PushUpMenu {
                bottomMargin: Theme.paddingMedium

                MenuItem {
                    visible: (filePath == "") ? false : true
                    text: filePath
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.highlightColor
                    onClicked: {
                        Clipboard.text = filePath;
                        outputNotifications.close()
                        outputNotifications.previewBody = qsTr("File path copied to the clipboard")
                        outputNotifications.publish()
                    }
                }

                Column {
                    width: parent.width
                    height: childrenRect.height

                    EditRow {
                        id: pullMenu
                        width: parent.width
                        height: childrenRect.height
                        myMenuButtonWidth: sizeBackgroundItemMainMenu
                        visible: !headerVisible
                    }

                    MainRow {
                        id: pullMenu2
                        width: parent.width
                        height: childrenRect.height
                        myMenuButtonWidth: sizeBackgroundItemMainMenuFirstRow
                    }

                    //TODO need refactoring for this row
                    Row {
                        width: parent.width
                        height: childrenRect.height

                        MenuButton {
                            width: parent.width / 3
                            mySource: "image://theme/icon-m-keyboard?" + (myTextArea.readOnly ? Theme.highlightColor : Theme.primaryColor);
                            myText: qsTr("R-only")
                            onClicked: {
                                if (!myTextArea.readOnly) {
                                    myTextArea.readOnly = true;
                                }
                                else {
                                    myTextArea.readOnly = false;
                                }
                            }
                        }

                        MenuButton {
                            width: parent.width / 3
                            mySource: "../img/icon-m-qnote.svg"
                            myText: qsTr("Quick note")
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("QuickNotePage.qml"))
                            }
                        }

                        MenuButton {
                            width: parent.width / 3
                            mySource: "../img/icon-m-code.svg";
                            myText: qsTr("Highlight")
                            onClicked: {
                                if (highlightingEnabled == false) {
                                    highlightingEnabled = true;
                                    //pageStatusChange(editorPage); //bug
                                    pageStack.replaceAbove(null, Qt.resolvedUrl("FirstPage.qml"), {filePath: filePath, highlightingEnabled: highlightingEnabled}, PageStackAction.Replace);

                                    outputNotifications.close()
                                    outputNotifications.previewBody = qsTr("Highlighting enabled");
                                    outputNotifications.publish()
                                }
                                else {
                                    highlightingEnabled = false;
                                    pageStack.replaceAbove(null, Qt.resolvedUrl("FirstPage.qml"), {filePath: filePath}, PageStackAction.Replace);

                                    outputNotifications.close()
                                    outputNotifications.previewBody = qsTr("Highlighting disabled");
                                    outputNotifications.publish()

                                }
                            }
                        }
                    }

                }

                MenuItem {
                    text: qsTr("Settings")
                    onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }

//                MenuItem {
//                    text: qsTr("Menu")
//                    onClicked: pageStack.push(Qt.resolvedUrl("MenuPage.qml"))
//                    visible: true
//                }
//                MenuItem {
//                    text: qsTr("Menu")
//                    onClicked: pageStack.push(Qt.resolvedUrl("MenuPage.qml"), {
//                                                  readOnly: myTextArea.readOnly,
//                                                  //showFormat: true,
//                                                  //title: "Select file",
//                                                  callback: setVariables
//                                              })
//                    visible: true
//                }
//            }

            Row {
                id: header
                height: hotActionsMenu.height
                width: parent.width
                anchors.bottom: parent.bottom
                visible: headerVisible || searchRowVisible //header visible if EditRow active or SearchRow active

                EditRow {
                    id: hotActionsMenu
                    width: parent.width
                    height: childrenRect.height
                    myMenuButtonWidth: sizeBackgroundItem
                    visible: !searchRowVisible
                }

                SearchRow {
                    width: parent.width
                    height: childrenRect.height
                    visible: searchRowVisible
                }
            }

            SilicaFlickable {
                id: editorView
                anchors.fill: parent
                anchors.bottomMargin: header.visible ? header.height : 0 // для сдвига при отключении quick actions menu
                contentHeight: myTextArea.height
                clip: true

                Label {
                    id: lineNumbers
                    y: 8
                    height: myTextArea.height
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: fontSize
                    text: "1"
                    visible: lineNumbersVisible
                }
                TextArea {
                    id: myTextArea
                    width: parent.width
                    font.family: fontType
                    font.pixelSize: fontSize
                    background: null
                    selectionMode: TextEdit.SelectCharacters
                    color: focus ? textColor : Theme.primaryColor
                    focus: true

                    text: documentHandler.text //for highlighting

                    onTextChanged: {
                        console.log("filePath = " + filePath, fontSize, font.family);
                        //console.log("Real lines: " + myTextArea._editor.lineCount);
                        saved = false;

                        //lineNumbers counter
                        lineNumberChanged();

                        //For cover:
                        charNumber = myTextArea.text.length;
                        linesNumber = numberOfLines();
                        wordsNumber = wordsCounter(myTextArea.text);
                        fileName = getName(filePath);

                        //Autosave
                        if (autosave) {
                            if (filePath!=="" && documentHandler.text !== "") {
                                py.call('editFile.autosave', [filePath, myTextArea.text], function(result) {}); // written myTextArea.text to fix autosaving
                            }
                        }
                    }

                    DocumentHandler {
                        id: documentHandler
                        target: myTextArea._editor
                        cursorPosition: myTextArea.cursorPosition
                        selectionStart: myTextArea.selectionStart
                        selectionEnd: myTextArea.selectionEnd
                        onTextChanged: {
                            myTextArea.text = documentHandler.text
                            myTextArea.update()
                        }
                    }

                }
                VerticalScrollDecorator { flickable: editorView }
            }


        }
    }

    onStatusChanged: {
        busy.running=true;

        if(highlightingEnabled) {
            pageStatusChange(editorPage);
        }

        if (status !== PageStatus.Active) {
            return
        } else {
            console.log(filePath)
            if (filePath!=="") {
                py.call('editFile.openings', [filePath], function(result) {
                    documentHandler.text = result;
                });
            }
        }

        busy.running=false;
    }

    Python {
        id: py

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../.'));
            importModule('editFile', function () {});
        }
        onError: {
            // when an exception is raised, this error handler will be called
            console.log('python error: ' + traceback);
            outputNotifications.close()
            outputNotifications.previewBody = qsTr("Error while opening/saving the file");
            outputNotifications.publish()
        }

        onReceived: console.log('Unhandled event: ' + data)
    }

}
