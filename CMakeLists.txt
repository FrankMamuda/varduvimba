cmake_minimum_required(VERSION 3.16)

project(varduvimba VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 6.2 COMPONENTS Quick Svg REQUIRED)

qt_add_executable(appvarduvimba
    main.cpp spellcheck.cpp spellcheck.h adbanner.cpp adbanner.h settings.cpp settings.h hapticfeedback.cpp hapticfeedback.h resources.qrc hunspell/affentry.cxx hunspell/affixmgr.cxx hunspell/csutil.cxx hunspell/filemgr.cxx hunspell/hashmgr.cxx hunspell/hunspell.cxx hunspell/hunzip.cxx hunspell/phonet.cxx hunspell/replist.cxx hunspell/suggestmgr.cxx
)

qt_add_qml_module(appvarduvimba
    URI varduvimba
    VERSION 1.0
    QML_FILES main.qml content/Banner.qml content/ColourButton.qml content/ImageButton.qml content/YesNoDialog.qml content/KeyBoard.qml content/KeyRow.qml content/LetterRow.qml content/NamedSwitch.qml content/Settings.qml content/Spinner.qml content/TextButton.qml
)

set_property(TARGET appvarduvimba APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

set_target_properties(appvarduvimba PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER varduvimba.factory12.org
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)
add_definitions( -DPRODUCTION_RELEASE )
target_include_directories(appvarduvimba PUBLIC include)
target_compile_definitions(appvarduvimba
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(appvarduvimba
    PRIVATE Qt6::Quick Qt6::Svg)



