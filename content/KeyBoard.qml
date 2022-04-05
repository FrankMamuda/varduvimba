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
 * Virtual keyboard
 */
Column {
    id: keyboard
    spacing: 0
    anchors.bottomMargin: 2

    // compact mode used only base letters and longPress to access sub letters
    property bool compact: mode === 0
    property int mode: 1

    property var letters: {
        0: [ 'AERTUIOP',     'SDFGHJKL',     '0ZCVBNM1' ],
        1: [ 'ĀEĒRTUŪIĪOPĻ', 'ASŠDFGĢHJKĶL', '0ZŽCČVBNŅM1' ],
        2: [ 'AĀBCČDEĒF',    'GĢHIĪJKĶL',    'ĻMNŅOPRSŠ',    '0TUŪVZŽ1' ] };

    property var subLetters: {
        0: [ 'ĀĒRTŪĪOP',     'ŠDFĢHJĶĻ',     '0ŽČVBŅM1' ],
        1: [],
        2: [] };

    onModeChanged: {
        lettersChanged();
    }

    // centre items on inital show
    Component.onCompleted: {
        for ( let item in children )
            children[item].anchors.horizontalCenter = keyboard.horizontalCenter;
    }

    /*
     * Restart button
     */
    Rectangle {
        id: toolBarRect
        color: root.palette['keyboard']
        width: parent.width
        height: ( toolBar.height ) * root.heightScale + 4

        Row {
            id: toolBar
            spacing: 64 * root.heightScale

            anchors.centerIn: parent
            anchors.bottomMargin: 16 * root.heightScale
            property int buttonWidth: 48 * root.heightScale
            property int buttonHeight: 32 * root.heightScale

            ImageButton {
                id: restartButton
                source: '../icons/restart.svg'
                color: 'transparent'
                width: toolBar.buttonWidth
                height: toolBar.buttonHeight
                borderColor: 'transparent'

                onClicked: {
                    console.log( 'Reset' );

                    if ( root.os === 'android' )
                        root.hapticFeedback.send( 3 );

                    if ( root.currentRow === 0 && !root.gameOver ) {
                        if ( root.os !== 'android' )
                            root.textInput.focus = true;
                        return;
                    }

                    if ( root.gameOver ) {
                        root.resetRows();
                    } else
                        resetDialog.open();

                    root.textInput.focus = true;
                }
            }

            /*
             * Give up button
             */
            ImageButton {
                source: '../icons/giveup.svg'
                width: toolBar.buttonWidth
                height: toolBar.buttonHeight
                borderColor: 'transparent'

                onClicked: {
                    if ( root.gameOver )
                        return;

                    if ( root.os === 'android' )
                        root.hapticFeedback.send( 3 );

                    if ( root.currentRow === 0 ) {
                        if ( root.os !== 'android' )
                            root.textInput.focus = true;
                        return;
                    }

                    if ( root.currentString !== root.word )
                        giveUpDialog.open();
                }
            }

            /*
             * Settings button
             */
            ImageButton {
                source: '../icons/settings.svg'
                width: toolBar.buttonWidth
                height: toolBar.buttonHeight
                borderColor: 'transparent'

                onClicked: {
                    if ( root.os === 'android' )
                        root.hapticFeedback.send( 3 );

                    settings.open();//.visible = true;
                }
            }
        }
    }

    Repeater {
        id: keyRows
        anchors.horizontalCenter: parent

        Component.onCompleted: {
            model = Qt.binding( function() { return keyboard.letters[mode].length; } )
        }

        KeyRow {
            letters: keyboard.letters[mode][index]
            subLetters: mode === 0 ? keyboard.subLetters[mode][index] : ''
            size: ( root.width - ( letters.length - 1 ) * spacing ) / letters.length
            specialSize: ( keyRows.itemAt( 0 ).width - ( size * ( letters.length - 2 ) +
                                                        ( spacing * ( letters.length - 1 )))) / 2
        }
    }
}
