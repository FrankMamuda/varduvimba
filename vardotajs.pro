QT += quick svg core

win32:RC_FILE = icon.rc

SOURCES += \
        adbanner.cpp \
        main.cpp \
        settings.cpp \
        spellcheck.cpp

resources.prefix = /$${TARGET}
RESOURCES += \
    resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

INCLUDEPATH += $$PWD/include/

win32 {
    QMAKE_LIBDIR += C:/msys64/mingw64/lib/
    INCLUDEPATH += C:/msys64/mingw64/include/
    LIBS += -lhunspell-1.7
}

android {
    ANDROID_ABI = $$QT_ARCH
    ANDROID_EXTRA_LIBS += $$PWD/libs/android/$${ANDROID_ABI}/libhunspell.so
    LIBS += -L$$PWD/libs/android/$${ANDROID_ABI}/ -lhunspell
    QMAKE_LIBDIR += $$PWD/libs/android/$${ANDROID_ABI}/
    DISTFILES += \
        android/AndroidManifest.xml
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android

    SOURCES += hapticfeedback.cpp
    HEADERS += hapticfeedback.h
}

HEADERS += \
    adbanner.h \
    settings.h \
    spellcheck.h

DISTFILES += \
    android/build.gradle \
    android/gradle.properties \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/drawable/ic_vimba.xml \
    android/res/drawable/ic_water.xml \
    android/res/mipmap-anydpi-v26/ic_launcher.xml \
    android/res/mipmap-anydpi-v26/ic_launcher_round.xml \
    android/res/values/libs.xml \
    android/src/org/factory12/vardotajs/HapticFeedback.java \
    android/src/org/factory12/vardotajs/AdBanner.java \
    content/Banner.qml \
    content/ColourButton.qml \
    content/ImageButton.qml \
    content/KeyBoard.qml \
    content/KeyRow.qml \
    content/LetterRow.qml \
    content/NamedSwitch.qml \
    content/Settings.qml \
    content/Spinner.qml \
    content/TextButton.qml \
    content/YesNoDialog.qml \
    main.qml \
    scripts/main.js

DEFINES += PRODUCTION_RELEASE
