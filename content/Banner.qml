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
import AdBanner

/*
 * Ad banner
 */
AdBanner {
    id: banner

    adMobId: root.adMobId

    Rectangle {
        id: rect
        color: '#88ffffff'
        border.color: 'black'
        border.width: 2
        visible: root.os !== 'android'

        // NOTE: this dummy is used only for debug purposes
        /*
        Text {
            anchors.centerIn: parent
            color: 'white'
            text: 'Sample ad text'
            font.bold: true
            font.pixelSize: 24
        }*/
    }
}
