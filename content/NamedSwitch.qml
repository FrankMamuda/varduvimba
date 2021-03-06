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
 * Simple switch with a description
 */
Row {
    id: namedSwitch
    spacing: Math.round( 16 * namedSwitch.contentScale )

    property string text: ''
    property bool checked: false
    property int pixelSize: Math.round( 24 * namedSwitch.contentScale )
    property Switch control: control
    property real contentScale: 1.0

    signal clicked

    Text {
        anchors.verticalCenter: namedSwitch.verticalCenter
        anchors.leftMargin: Math.round( 8 * namedSwitch.contentScale )
        font.pixelSize: namedSwitch.pixelSize
        text: namedSwitch.text
        font.bold: true
        style: Text.Raised
        styleColor: '#000000'
        color: 'white'
    }

    Switch {
        anchors.verticalCenter: namedSwitch.verticalCenter
        id: control
        text: ''
        checked: parent.checked

        indicator: Rectangle {
            implicitWidth: implicitHeight * 2
            implicitHeight: Math.round( 28 * namedSwitch.contentScale )
            x: control.leftPadding
            y: parent.height / 2 - height / 2
            radius: Math.round( 13 * namedSwitch.contentScale )
            color: control.checked ? "#17a81a" : "#ffffff"
            border.color: control.checked ? "#17a81a" : "#cccccc"

            Rectangle {
                x: control.checked ? parent.width - width : 0
                width: Math.round( 28 * namedSwitch.contentScale )
                height: Math.round( 28 * namedSwitch.contentScale )
                radius: width / 2
                color: control.down ? "#cccccc" : "#ffffff"
                border.color: control.checked ? ( control.down ? "#17a81a" : "#21be2b" ) : "#999999"
            }
        }

        onClicked: {
            if ( root.os === 'android' )
                root.hapticFeedback.send( 3 );

            namedSwitch.clicked();
        }
    }
}
