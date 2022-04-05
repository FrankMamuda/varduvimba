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

/*
 * Simple buttoned spinbox with a description
 */

Item {
    id: spinner

    property string text: ''
    property int pixelSize: 24
    property int value: 1
    property int min: 0
    property int max: 10
    property bool textMode: false
    property var textValues: []

    width: bigRow.width
    height: bigRow.height

    Row {
        id: bigRow
        spacing: 16

        Text {
            anchors.verticalCenter: bigRow.verticalCenter
            font.pixelSize: spinner.pixelSize
            text: spinner.text
            font.bold: true
            style: Text.Raised
            styleColor: 'black'
            color: 'white'
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            width: row.width
            height: row.height
            radius: height / 2

            Row {
                id: row
                spacing: 12
                anchors.centerIn: parent

                ImageButton {
                    anchors.verticalCenter: row.verticalCenter
                    width: 28
                    height: 28
                    radius: width / 2
                    source: '../icons/arrow_left.svg'
                    enabled: spinner.textMode || spinner.value > spinner.min
                    font.pixelSize: spinner.pixelSize * 0.75
                    color: 'transparent'

                    onReleased: {
                        // wrap around
                        if ( spinner.textMode ) {
                            if ( spinner.value === spinner.min ) {
                                spinner.value = spinner.max;
                                return;
                            }
                        }

                        if ( root.os === 'android' )
                            root.hapticFeedback.send( 3 );

                        spinner.value--;
                    }
                }

                Text {
                    anchors.verticalCenter: row.verticalCenter
                    font.pixelSize: spinner.pixelSize
                    text: spinner.textMode ? spinner.textValues[spinner.value] : spinner.value
                    font.bold: true
                    style: Text.Raised
                    styleColor: 'white'
                    color: 'black'
                    verticalAlignment: Text.AlignVCenter
                }

                ImageButton {
                    anchors.verticalCenter: row.verticalCenter
                    width: 28
                    height: 28
                    radius: width / 2
                    source: '../icons/arrow_right.svg'
                    enabled: spinner.textMode || spinner.value < spinner.max
                    font.pixelSize: spinner.pixelSize * 0.75
                    color: 'white'

                    onReleased: {
                        // wrap around
                        if ( spinner.textMode ) {
                            if ( spinner.value === spinner.max ) {
                                spinner.value = spinner.min;
                                return;
                            }
                        }


                        if ( root.os === 'android' )
                            root.hapticFeedback.send( 3 );

                        spinner.value++;
                    }
                }
            }
        }
    }
}
