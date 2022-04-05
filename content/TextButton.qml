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
 * Simple button with text
 */
AbstractButton {
    id: button

    width: textItem.width + 16
    height: textItem.height + 8
    property int radius: 8

    Text {
        id: textItem
        anchors.centerIn: parent
        font.pixelSize: 20
        text: button.text
        font.bold: true
        style: Text.Raised
        styleColor: '#000000'
        color: 'white'
    }

    property string color: 'transparent'

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: parent.color
        border.width: 2
        border.color: 'white'
    }
}
