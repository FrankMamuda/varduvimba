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
import QtQuick.Controls

Dialog {
    id: dialog
    anchors.centerIn: parent
    bottomMargin: root.banner.height
    modal: true
    title: 'Title'

    property string yes: 'Yes'
    property string no: 'No'

    header: Item {}

    background: Rectangle {
        color: 'transparent'
    }

    Overlay.modal: Rectangle {
        color: '#aa000000'
    }

    contentItem: Column {
        id: column
        anchors.centerIn: parent
        spacing: Math.round( 16 * column.contentScale )
        property real contentScale: Math.min( root.widthScale, root.heightScale )

        Component.onCompleted: {
            for ( let item in children )
                children[item].anchors.horizontalCenter = column.horizontalCenter;
        }

        Item {
            height: Math.round( header.height + 16 * column.contentScale )
            width: header.width

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.palette['activeBorder']
                opacity: .4
                width: root.width
                height: Math.round( header.height + 16 * column.contentScale )
            }

            Text {
                id: header
                font.pixelSize: Math.round( 34 * column.contentScale )
                anchors.centerIn: parent
                text: dialog.title
                font.bold: true
                style: Text.Raised
                styleColor: '#000000'
                color: 'white'
                wrapMode: Text.WordWrap
                width: column.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ColourButton {
            text: dialog.yes
            fontPixelSize: Math.round( 28 * column.contentScale )

            onClicked: {
                if ( root.os === 'android' )
                    root.hapticFeedback.send( 3 );

                dialog.accept();
            }
        }

        ColourButton {
            text: dialog.no
            color: root.palette['red']
            fontPixelSize: Math.round( 28 * column.contentScale )

            onClicked: {
                if ( root.os === 'android' )
                    root.hapticFeedback.send( 3 );

                dialog.reject();
            }
        }
    }

    onClosed: {
        // restore text input focus (it sometimes looses focus for no reason)
        if ( root.os !== 'android' )
            root.textInput.focus = true;
    }
}
