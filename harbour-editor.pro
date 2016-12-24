# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-editor

CONFIG += sailfishapp

SOURCES += src/harbour-editor.cpp

OTHER_FILES += qml/harbour-editor.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-editor.changes.in \
    rpm/harbour-editor.spec \
    rpm/harbour-editor.yaml \
    translations/*.ts \
    harbour-editor.desktop \
    qml/editFile.py #You can find better place :)

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-editor-de.ts \
	translations/harbour-editor-ru.ts \
	translations/harbour-editor-sv.ts \
	translations/harbour-editor-fr.ts \
	translations/harbour-editor-es.ts

DISTFILES += \
    qml/pages/AboutPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/FileChooserPage.qml \
    qml/components/MenuButton.qml \
    qml/pages/SaveAsPage.qml \
    qml/pages/HistoryPage.qml
