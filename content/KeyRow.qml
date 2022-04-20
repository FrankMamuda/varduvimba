/*
 * Copyright (C) 2022 Armands Aleksejevs
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
import QtQuick.Shapes 1.2

/*
 * A row of letters used in the keyboard
 */
Row {
    id: row
    spacing: 0

    // placeholders
    property string letters: 'ABCDEFG'
    property string subLetters: 'ABCDEFG'

    // letter colours and sizes (backspace/return are 'special' keys)
    property int size: 32
    property int specialSize: 50

    Repeater {
        id: repeater
        model: row.letters.length

        /*
         * Letter key
         */
        Rectangle {
            id: key

            // special keys can expand to consume available space on the side
            width: key.special ? specialSize : row.size

            height: Math.round( 48 * root.heightScale )

            // 0 - backspace; 1 - enter/return; a-z - normal button
            property bool special: row.letters[index] === '0' || row.letters[index] === '1'
            property string letter: row.letters[index]
            property string subLetter: index >= row.subLetters.length ? ' ' : row.subLetters[index]
            property bool incorrect: false
            property bool incorrectSub: false
            color: root.palette['keyboard']

            Rectangle {
                id: baseRect
                anchors.fill: parent
                anchors.margins: root.keyboard.compact ? 2 : 1
                radius: 4
            }

            // update key colours based on used letters (correct/out of place/etc.)
            Component.onCompleted: {
                baseRect.color = Qt.binding( function() {
                    if ( root.usedLetters.indexOf( key.letter ) !== -1 ) {
                        if ( root.correctLetters.indexOf( key.letter ) !== -1 )
                            return root.palette['green'];

                        if ( root.word.indexOf( key.letter ) !== -1 )
                            return root.palette['orange'];

                        key.incorrect = true;
                        return root.palette['dark'];
                    }

                    key.incorrect = false;
                    return root.palette['keyboard'];
                } );
            }

            /*
             * 'SubRect' - used in compact key mode
             *             this is basically a split key overlay
             *             that indicates colour code of the subletter
             */
            Rectangle {
                visible: root.keyboard.compact && !key.special
                id: subrect
                anchors.right: key.right
                anchors.top: key.top
                width: key.width / 2
                height: key.height - 4
                anchors.margins: root.keyboard.compact ? 2 : 0
                radius: 4

                // update key colours based on used letters (correct/out of place/etc.)
                Component.onCompleted: {
                    subrect.color = Qt.binding( function() {
                        if ( root.usedLetters.indexOf( key.subLetter ) !== -1 ) {
                            if ( root.correctLetters.indexOf( key.subLetter ) !== -1 )
                                return root.palette['green'];

                            if ( root.word.indexOf( key.subLetter ) !== -1 )
                                return root.palette['orange'];

                            incorrectSub = true;
                            return root.palette['dark'];
                        }

                        incorrectSub = false;
                        return root.palette['keyboard'];
                    } );
                }

                // clipper - cuts off rounded sides on the left
                Rectangle {
                    id: clipper
                    width: key.width / 4
                    height: parent.height
                    color: parent.color
                    anchors.margins: root.keyboard.compact ? 1 : 0
                }
            }

            // mouseover highlight
            Rectangle {
                id: highlight
                anchors.fill: parent
                anchors.margins: 2
                color: 'black'
                opacity: 0.2
                visible: root.keyboard.compact
                radius: 4
            }

            /*
             * Letter
             */
            Text {
                id: text
                visible: !key.special
                font.pixelSize: Math.round( 26 * Math.min( root.widthScale, root.heightScale ))
                font.bold: true
                style: Text.Raised
                styleColor: root.palette['dark']
                color: 'white'
                bottomPadding: 2 * Math.min( root.widthScale, root.heightScale )
                width: showSubletter ? key.width / 2 : key.width
                text: ( showSubletter ? '  ' : '' ) + key.letter
                anchors.verticalCenter: parent.verticalCenter;
                horizontalAlignment: Text.AlignHCenter
                opacity: key.incorrect && !root.compact ? .5 : 1
            }

            Text {
                id: subText
                visible: !key.special && showSubletter
                font.pixelSize: Math.round( 26 * Math.min( root.widthScale, root.heightScale ))
                font.bold: true
                style: Text.Raised
                styleColor: '#000000'
                color: 'white'
                bottomPadding: 2 * Math.min( root.widthScale, root.heightScale )
                width: showSubletter ? key.width / 2 : key.width
                text: key.subLetter + '  '
                x: key.width / 2
                anchors.verticalCenter: parent.verticalCenter;
                horizontalAlignment: Text.AlignHCenter
                opacity: key.incorrectSub && !root.compact ? .5 : 1
            }

            property bool showSubletter: root.keyboard.compact && ( key.letter !== key.subLetter )

            // backspace icon
            Image {
                visible: row.letters[index] === '0'
                source: '../icons/left.svg'
                anchors.centerIn: parent
                sourceSize.width: Math.round( text.font.pixelSize * 1.1 );
                sourceSize.height: Math.round( text.font.pixelSize * 1.1 );
            }

            // accept icon for the return/enter key
            Image {
                visible: row.letters[index] === '1'
                source: '../icons/accept.svg'
                anchors.centerIn: parent
                sourceSize.width: Math.round( text.font.pixelSize * 1.1 );
                sourceSize.height: Math.round( text.font.pixelSize * 1.1 );
            }

            /*
             * MouseArea - click handler
             */
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                property string letter: ''

                // simple press - append base letter
                onPressed: {
                    mouseArea.letter = key.letter;

                    if ( key.letter === '0' || key.letter === '1' )
                        return;

                    if ( root.os === 'android' || !root.production ) {
                        if ( key.letter !== '0' && key.letter !== '1' && root.currentString.length === root.word.length )
                            return;

                        const pos = repeater.mapFromItem( key, mouseArea.x, mouseArea.y );
                        popup.x = pos.x + mouseArea.width / 2 - popup.background.width / 2;
                        popup.y = pos.y - popup.background.height;
                        popup.letter = key.letter;

                        if ( !root.gameOver )
                            popup.open();
                    }
                }

                pressAndHoldInterval: 200

                // long press - append subletter
                onPressAndHold: {
                    if ( key.letter === '0' ) {
                        root.press( '0' );
                        timer.start();
                        return;
                    }

                    if ( !root.keyboard.compact )
                        return;

                    popup.letter = key.subLetter;
                    mouseArea.letter = key.subLetter;
                }

                onReleased: {
                    timer.stop();


                    if ( root.gameOver ) {
                        console.log( 'Ignore input' )
                        return;
                    }

                    if ( root.currentString.length === 0 && key.letter === '0' ) {
                        console.log( 'Ignore backspace' )
                        return;
                    }

                    if (( root.currentString.length < root.word.length ) && key.letter === '1' ) {
                        console.log( 'Ignore enter' )
                        return;
                    }

                    if ( root.os === 'android' && !root.gameOver ) {
                        if (( root.currentString.length < root.word.length ) || key.letter === '0' || key.letter === '1' )
                            root.hapticFeedback.send( 3 );
                    }

                    console.log( 'Press: ' + mouseArea.letter )
                    root.press( mouseArea.letter );
                    root.save();

                    if ( popup.open )
                        popup.close();
                }
            }
        }
    }

    Timer {
        id: timer
        running: false
        interval: 150
        repeat: true
        onTriggered: {
            root.press( '0' );
        }
    }

    /*
     * Key popup (similar to gboard)
     */
    Popup {
        id: popup
        scale: Math.min( root.widthScale, root.heightScale )

        // TODO: this must be scaled appropriately

        property string letter: ''
        property int size: 64

        onOpened: {
            popupTimer.start();
        }

        onClosed: {
            if ( popupTimer.running )
                popupTimer.stop();
        }

        Timer {
            id: popupTimer
            running: false
            interval: 1000
            repeat: false
            onTriggered: {
                if ( popup.open )
                    popup.close();
            }
        }

        background: Item {
            width: popup.size
            height: popup.size

            Shape {
                x: 4
                y: 4
                id: circle
                property real r: popup.size / 2
                width: popup.size
                height: popup.size

                ShapePath {
                    strokeColor: 'transparent'
                    startX: - circle.r
                    startY: - circle.r

                    fillGradient: RadialGradient {
                        centerX: popup.size / 2; centerY: popup.size / 2
                        centerRadius: popup.size / 2
                        focalX: centerX;
                        focalY: centerY
                        GradientStop { position: 0; color: 'black' }
                        GradientStop { position: 1; color: 'transparent' }
                    }

                    PathAngleArc {
                        centerX: popup.size / 2; centerY: popup.size / 2
                        radiusX: popup.size / 2; radiusY: popup.size / 2
                        sweepAngle: 360
                    }
                }
            }

            Rectangle {
                width: popup.size
                height: popup.size
                radius: popup.size / 2
                color: root.palette['keyboardPopup']

                Text {
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.centerIn: parent
                    color: root.darkMode ? 'white' : 'black'
                    text: popup.letter
                    font.pixelSize: popup.size / 2
                    font.bold: true
                }
            }
        }
    }
}
