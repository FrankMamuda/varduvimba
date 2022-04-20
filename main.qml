/*
 * Copyright (C) 2021 Armands Aleksejevs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 *
 */


/*
 * imports
 */
import QtQuick
import QtQuick.Controls
import 'content' as Content
import 'scripts/main.js' as MainJS

/*
 * game window
 */
Window {
    id: root
    minimumWidth: 240
    minimumHeight: 480
    width: 411
    height: 823
    visible: true
    title: root.strings[root.locale]['title']

    /*
     * os specific variables
     */
    property string os: 'generic'


    property real heightScale: height / 720
    property real widthScale: width / 480

    /*
     * C++ objects
     */
    property var spellCheck;
    property var settings;
    property var hapticFeedback;

    /*
     * game state and initial settings
     */
    property string word: root.strings[root.locale]['default']
    property string usedLetters: ''
    property string correctLetters: ''
    property string currentString: ''
    property string locale: 'en_US'
    property string path: ''

    property int currentRow: 0
    property int initialRows: 6
    property int initialLength: 5
    property int lastRow: 0

    property var usedWords: []

    property bool badWord: false
    property bool gameOver: false
    property bool lost: false
    property bool thinking: false
    property bool animationsDisabled: false
    property bool darkMode: true
    property bool production

    // default is admob test id for the banner
    property string adMobId: 'ca-app-pub-3940256099942544/6300978111'

    /*
     * external functions
     */
    property var save: MainJS.save
    property var reset: MainJS.reset
    property var load: MainJS.load
    property var press: MainJS.press
    property var resetRows: MainJS.resetRows
    property var setupAds: MainJS.setupAds
    property var addWord: function() { root.spellCheck.addWord( root.currentString ); }

    /*
     * references to items
     */
    property TextInput textInput: textInput
    property Content.KeyBoard keyboard: keyboard
    property Rectangle keyboardRect: keyboardRect
    property Content.YesNoDialog addWordDialog: addWordDialog
    property Content.YesNoDialog giveUpDialog: giveUpDialog
    property Content.YesNoDialog resetDialog: resetDialog

    // avoiding qsTr for now
    property var locales: [ 'en_US', 'lv_LV' ];
    property var strings: {
        'lv_LV': {
            'giveup': 'Padodies?',
            'giveup_yes': 'Jā, neko nemāku!',
            'giveup_no': 'Nē, nekad!',
            'new': 'Jaunu vārdu?',
            'new_yes': 'Jā, šis nesanāk!',
            'new_no': 'Nē, uzgaidi!',
            'unknown': 'Vārds neeksistē!\nPievienot vārdnīcai?',
            'reveal': 'Nepaveicās! Vārds ir \'',
            'win': 'Uzvara!',
            'settings': 'Uzstādījumi',
            'letters': 'Burtu skaits',
            'guesses': 'Minējumu skaits',
            'dark': 'Tumšais režīms',
            'close': 'Aizvērt',
            'default': 'VARDE',
            'title': 'Vārdu Vimba',
            'add_title': 'Pievienot vārdu \'',
            'add_title2': '\' vārdnīcai?',
            'add_yes': 'Apsolu, tāds eksistē!',
            'add_no': 'Pārdomāju!',
            'ads_yes': 'JĀREKLĀMĀM',
            'ads_no': 'NĒREKLĀMĀM',
            'language': 'Valoda',
            'latvian': 'latviešu',
            'english': 'angļu',
            'help_title': 'Kā spēlēt',
            'help_desc0': 'Uzmini vārdu vairākos mēģinājumos. Pēc katra minējuma, burta krāsa norādīs, cik tuvu esi pareizajam vārdam.',
            'help_desc1': 'Burts \'S\' ir pareizajā vietā.',
            'help_desc2': 'Vārds satur burtu \'O\', tikai citā vietā.',
            'help_desc3': 'Burts \'Ž\' nav vārdā vispār.',
            'help_desc4': 'Vārds nav vārdnīcā. Uzspied, lai pievienotu!',
            'help_word0': 'TUSĒT',
            'help_word1': 'MODES',
            'help_word2': 'ŽAUNA',
            'help_word3': 'DRON',
        },
        'en_US': {
            'giveup': 'Give up?',
            'giveup_yes': 'Yes, I failed!',
            'giveup_no': 'No, never!',
            'new': 'New word?',
            'new_yes': 'Yes, I\'m stuck!',
            'new_no': 'No, wait!',
            'unknown': 'Word does not exist!\nAdd to dictonary?',
            'reveal': 'Bad luck! \'',
            'reveal2': '\' is the word.',
            'win': 'Good job!',
            'settings': 'Settings',
            'letters': 'Letter count',
            'guesses': 'Number of guesses',
            'dark': 'Dark mode',
            'close': 'Close',
            'default': 'FROGS',
            'title': 'Word Vimba',
            'add_title': 'Add word \'',
            'add_title2': '\' to the dictionary?',
            'add_yes': 'I promise it exists!',
            'add_no': 'Changed my mind.',
            'ads_yes': 'GIVEMEADS',
            'ads_no': 'NOMOREADS',
            'language': 'Language',
            'latvian': 'latvian',
            'english': 'english',
            'help_title': 'How to play',
            'help_desc0': 'Guess the word in multiple tries. After each guess letter background will display how close you are to solving the puzzle.',
            'help_desc1': 'The letter \'S\' is in the correct spot.',
            'help_desc2': 'Word contains the letter \'O\', but in a different spot.',
            'help_desc3': 'Words does not contain the letter \'Q\'.',
            'help_desc4': 'Word is not in the dictionary. Tap to add it!',
            'help_word0': 'FISHY',
            'help_word1': 'BORED',
            'help_word2': 'QUITS',
            'help_word3': 'NSFW',
        },
    }

    Component.onCompleted: {
        MainJS.load();

        if ( !root.word.length )
            root.word = root.spellCheck.generateRandomWord( root.word.length )

        root.usedLetters = Qt.binding( function() {
            if ( root.currentRow === 0 )
                return '';

            let used = '';
            for ( let y = 0; y < root.usedWords.length; y++ ) {
                const w = root.usedWords[y];

                for ( let k = 0; k < w.length; k++ ) {
                    const c = w[k];

                    if ( used.indexOf( c ) === -1 )
                        used += c;
                }
            }

            return used;
        } );

        root.correctLetters = Qt.binding( function() {
            if ( root.currentRow === 0 )
                return '';

            let correct = '';
            for ( let y = 0; y < root.usedWords.length; y++ ) {
                const w = root.usedWords[y];

                for ( let k = 0; k < w.length; k++ ) {
                    const c0 = w[k];
                    const c1 = root.word[k];

                    if ( c0 === c1 )
                        correct += c0;
                }
            }

            return correct;
        } );

        // set up ads if any
        root.setupAds();

        // production warning
        if ( root.production ) {
            console.log( "############# WARNING! ################" )
            console.log( "#         PRODUCTION BUILD            #" )
            console.log( "#######################################" )
        }
    }

    /*
     * Canvas - the game board
     */
    Rectangle {
        id: canvas
        anchors.fill: parent
        color: root.palette['base']

        /*
         * invisible TextInput for keyboard based systems
         */
        TextInput {
            id: textInput
            focus: true
            enabled: root.os != 'android'
            anchors.centerIn: parent
            visible: false

            // accepts only letters in latvian
            validator: RegularExpressionValidator {
                regularExpression: root.locale === 'lv_LV' ? /[ĀEĒRTUŪIĪOPĻASŠDFGĢHJKĶLZŽCČVBNŅM]/i : /[QWERTYUIOPASDFGHJKLZXCVBNM]/i
            }

            property string current: ''

            // handle letters
            onTextChanged: {
                if ( root.os === 'android' )
                    return

                if ( textInput.text.length === 1 ) {
                    textInput.current = textInput.text;
                    root.press( textInput.current.toUpperCase());
                    root.save();
                }

                textInput.text = ''
            }

            // handle backspace key (16777219)
            Keys.onPressed: ( event ) => {
                                if ( root.os === 'android' )
                                return

                                if ( event.key === 16777219 ) {
                                    root.press( '0' );
                                    root.save();
                                }
                            }

            // handle return key
            Keys.onReturnPressed: {
                if ( root.os === 'android' )
                    return

                root.press( '1' );
                root.save();
            }
        }

        /*
         * Letter rows
         */
        Column {
            id: letterColumn
            topPadding: 4
            leftPadding: 2
            rightPadding: 2
            anchors.top: canvas.top
            anchors.horizontalCenter: canvas.horizontalCenter
            spacing: 4;

            Repeater {
                id: letterRows
                model: root.initialRows

                Content.LetterRow {
                    id: letterRow
                    rowIndex: index

                    property int maxWidth: ( root.width - (( root.word.length + 1 ) * letterRow.spacing ) ) / root.word.length
                    property int maxHeight: ( root.height - keyboard.height - banner.height - ( 32 /*messageRect.height + 4*/ ) - (( root.initialRows + 1 ) * letterColumn.spacing ) ) / root.initialRows
                    size: Math.round( Math.min( 96 * root.heightScale, Math.min( maxHeight, maxWidth )))

                    state: 'inactive'
                }
            }
        }
        /*
         * Custom keyboard
         */
        Rectangle {
            id: keyboardRect
            width: root.width
            anchors.bottom: root.banner.parent.top
            height: keyboard.height
            color: root.palette['inactive']

            Content.KeyBoard {
                id: keyboard
                width: parent.width
            }
        }

        /*
         * Yes, I hate ads - im sorry
         */
        Rectangle {
            id: bannerRect
            x: 0

            anchors.bottom: canvas.bottom

            width: root.width
            height: banner.height

            color: root.palette['keyboard']

            Content.Banner {
                x: 0
                id: banner
            }
        }

        Rectangle {
            id: messageRect

            visible: root.gameOver || root.badWord
            height: message.height
            width: message.width * ( root.lost ? 1.1 : 1.25 )
            color: root.lost || root.badWord ? root.palette['red'] : root.palette['green']
            radius: message.height / 2
            scale: messageScale //Math.round( Math.min( root.heightScale, root.widthScale ) * messageScale )
            property real messageScale: 0.0

            opacity: 0

            x: letterColumn.x + letterColumn.width / 2 - width / 2
            y: letterColumn.y + ( letterColumn.height / root.initialRows ) * ( root.lastRow + ( root.badWord ? 2 : 1 )) + 4

            states: [
                State {
                    name: "inactive"
                    PropertyChanges {
                        target: messageRect
                        opacity: 0
                    }
                },
                State {
                    name: "active"
                    PropertyChanges {
                        target: messageRect
                        opacity: 1
                    }
                }
            ]

            state: ( root.gameOver || root.badWord ) ? 'active' : 'inactive'

            transitions: [
                Transition {
                    SequentialAnimation {
                        PauseAnimation {
                            duration: root.animationsDisabled ? 0 : 500
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                properties: 'opacity'
                                from: 0.0
                                to: 1.0
                                target: messageRect;
                                easing.type: Easing.InOutBack
                                duration: 150
                            }

                            NumberAnimation {
                                properties: 'messageScale'
                                target: messageRect;
                                to: 1.5;
                                duration: 150
                                easing.type: Easing.InOutBack
                                easing.amplitude: 2.0
                                easing.period: 1.5
                            }
                        }

                        NumberAnimation {
                            properties: 'messageScale'
                            target: messageRect;
                            to: 1;
                            duration: 150
                            easing.type: Easing.OutElastic;
                            easing.amplitude: 2.0;
                            easing.period: 1.5
                        }
                    }
                }
            ]

            Text {
                id: message
                anchors.centerIn: parent
                font.pixelSize: Math.round((( root.badWord || root.lost ) ? ( Math.round(( 20 + root.word.length ) * ( -0.83 ) + ( root.locale === 'lv_LV' ? 46 : 45 ))) : 32 ) * Math.min( root.widthScale, root.heightScale ))
                font.bold: true
                style: Text.Raised
                styleColor: '#000000'
                color: 'white'
                horizontalAlignment: Text.AlignHCenter

                Component.onCompleted: {
                    text = Qt.binding( function() {
                        if ( root.badWord )
                            return root.strings[root.locale]['unknown'];

                        if ( root.lost ) {
                            if ( root.locale === 'lv_LV' ) {
                                return root.strings[root.locale]['reveal'] + root.word + '\'';
                            } else if ( root.locale === 'en_US' ) {
                                return root.strings[root.locale]['reveal'] + root.word + root.strings[root.locale]['reveal2'];
                            }
                            return '';
                        }

                        return root.strings[root.locale]['win'];
                    } );
                }
            }
        }

        /*
         * Settings dialog
         */
        Content.Settings {
            id: settings
        }

        /*
         * Help dialog
         */
        Content.Help {
            id: help
        }

        /*
         * GiveUp dialog
         */
        Content.YesNoDialog {
            id: giveUpDialog

            title: root.strings[root.locale]['giveup']
            yes: root.strings[root.locale]['giveup_yes']
            no: root.strings[root.locale]['giveup_no']

            onAccepted: {
                root.lost = true;
                root.gameOver = true;
                root.textInput.focus = true;
                root.save();
            }
        }

        /*
         * Reset dialog
         */
        Content.YesNoDialog {
            id: resetDialog

            title: root.strings[root.locale]['new']
            yes: root.strings[root.locale]['new_yes']
            no: root.strings[root.locale]['new_no']

            onAccepted: {
                root.resetRows();
                root.textInput.focus = true;
            }
        }

        /*
         * AddWord dialog
         */
        Content.YesNoDialog {
            id: addWordDialog

            title: root.strings[root.locale]['add_title'] + root.currentString + root.strings[root.locale]['add_title2']
            yes: root.strings[root.locale]['add_yes']
            no: root.strings[root.locale]['add_no']

            onAccepted: {
                root.addWord();
                root.press( '1' );
                root.textInput.focus = true;
                root.save();
            }
        }
    }

    property var palette: {
        'green': '#23c54e',
        'red': '#c5234e',
        'orange': '#eab407',
        'inactive': root.darkMode ? '#344154' : '#aaaaaa',
        'keyboard': root.darkMode ? '#344154' : '#aaaaaa',
        'keyboardPopup': root.darkMode ? '#303e51' : '#aaaaaa',
        'activeBorder': '#788982',
        'border': '#485772',
        'dark': root.darkMode ? 'black' : '#ff888888',
        'light': root.darkMode ? 'white' : 'black',
        'base': root.darkMode ? '#0f182b' : '#ffffff' }

    property Timer timer: timer
    property Content.Banner banner: banner
}
