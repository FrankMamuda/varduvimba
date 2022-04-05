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
import QtQuick 2.0

/*
 * Simple coloured button
 */
Rectangle {
    id: button
    height: textItem.height
    width: textItem.width * 1.25
    color: root.palette['green']
    radius: textItem.height / 2

    property string text: 'Yes'
    property string textColor: 'white'
    property string styleColor: '#000000'


    signal clicked

    Rectangle {
        anchors.fill: parent
        opacity: .2
        visible: mouseArea.containsMouse
        radius: button.height / 2
    }

    Text {
        id: textItem
        anchors.centerIn: parent
        font.pixelSize: 28
        text: button.text
        font.bold: true
        style: Text.Raised
        styleColor: button.styleColor
        color: button.textColor
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }

    property var onClicked
}
