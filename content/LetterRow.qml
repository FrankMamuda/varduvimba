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

/*
 * A row of letters
 */
Row {
    id: row
    spacing: 4

    property var word: rowIndex === root.currentRow ? root.currentString : rowIndex < root.currentRow ? root.usedWords[rowIndex] : '     '
    property int rowIndex: 0
    property Repeater letters: repeater
    property int size: 64

    // resets the state of all letters to inactive
    property var reset: function() {
        for ( let y = 0; y < letters.count; y++ ) {
            const item = letters.itemAt( y );
            item.letter.state = 'inactive';
        }
    }

    Repeater {
        id: repeater
        model: root.word.length

        Item {
            width: row.size
            height: row.size
            property Rectangle letter: letter
            property Text textItem: text

            /*
             * Letter key
             */
            Rectangle {
                id: letter
                width: row.size
                height: row.size
                radius: row.size / 8
                border.color: ( row.rowIndex === root.currentRow && !root.gameOver ) ? root.palette['activeBorder'] : root.palette['border']
                state: 'inactive'
                color: 'transparent'
                border.width: 3
                anchors.centerIn: parent
                property real widthScale: 1.0

                /*
                 * Scaler - letters can dynamically adjust to the screen size
                 */
                transform: Scale {
                    origin.x: width / 2
                    xScale: letter.widthScale
                    yScale: 1.0
                }

                /*
                 * Transition - handles the 'flip' effect during state change
                 */
                transitions: [
                    Transition {
                        enabled: !root.animationsDisabled

                        SequentialAnimation {
                            // width to zero
                            NumberAnimation {
                                properties: 'widthScale'
                                target: letter;
                                to: 0;
                                duration: 150
                            }

                            // change colour instantly
                            ColorAnimation {}

                            // zero to original width
                            NumberAnimation {
                                properties: 'widthScale'
                                target: letter;
                                to: 1;
                                duration: 150
                            }
                        }
                    }
                ]

                /*
                 * States - letter states (colour coded)
                 *          to indicate correct/incorrect guesses
                 */
                states: [
                    State {
                        name: "inactive"
                        PropertyChanges {
                            target: letter
                            color: 'transparent'
                            border.width: 3
                        }
                    },
                    State {
                        name: "incorrect"
                        PropertyChanges {
                            target: letter
                            color: root.palette['inactive']
                            border.width: 0
                        }
                        PropertyChanges {
                            target: text
                            opacity: .75
                        }
                    },
                    State {
                        name: "outOfPlace"
                        PropertyChanges {
                            target: letter
                            color: root.palette['orange']
                            border.width: 0
                        }
                    },
                    State {
                        name: "correct"
                        PropertyChanges {
                            target: letter
                            color: root.palette['green']
                            border.width: 0
                        }
                    },
                    State {
                        name: "badword"
                        PropertyChanges {
                            target: letter
                            color: root.palette['red']
                            border.width: 0
                        }
                    }
                ]

                Rectangle {
                    id: highlight
                    anchors.fill: parent
                    radius: row.size / 8
                    color: 'white'
                    opacity: 0.2
                    visible: mouseArea.containsMouse && !root.gameOver
                }

                /*
                 * Letter
                 */
                Text {
                    id: text
                    anchors.centerIn: parent
                    font.pixelSize: 40 * ( row.size / 64 )// * root.heightScale
                    text: row.word.length <= index ? ' ' : row.word[index]
                    font.bold: true
                    style: Text.Raised
                    styleColor: ( letter.state === 'inactive' && !root.darkMode ) ? 'transparent' : root.palette['dark']
                    color: !root.darkMode ? ( letter.state === 'inactive' ? 'black' : 'white' ) : root.palette['light']
                    bottomPadding: ( root.os === 'android' ? 2 : 6 )// *  root.heightScale
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    state: text.text === ' ' ? 'empty' : 'full'

                    states: [
                        State { name: "empty" },
                        State { name: "full"  }
                    ]

                    transitions: [
                        Transition {
                            enabled: !root.animationsDisabled

                            SequentialAnimation {
                                // width to zero
                                NumberAnimation {
                                    properties: 'scale'
                                    target: text;
                                    from: 0.2
                                    to: 1.2;
                                    duration: 50
                                    easing.overshoot: 2
                                    easing.type:Easing.InOutBack
                                    easing.amplitude: 2
                                }

                                // zero to original width
                                NumberAnimation {
                                    properties: 'scale'
                                    target: text;
                                    from: 1.2
                                    to: 1.0;
                                    duration: 50
                                    easing.type:Easing.InOutBack

                                }
                            }
                        }
                    ]
                }

                /*
                 * Click handler - allows to easily add previously used letters
                 */
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: true

                    onClicked: {
                        if ( root.gameOver )
                            return;

                        if ( letter.state === 'badword' ) {
                            root.addWordDialog.open();

                            return;
                        }

                        root.press( text.text );
                    }
                }
            }
        }
    }
}
