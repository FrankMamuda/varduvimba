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

Popup {
    id: help
    anchors.centerIn: parent
    modal: true
    property string title: root.strings[root.locale]['help_title']
    closePolicy: Popup.CloseOnPressOutside

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
        width: root.width / column.contentScale;

        /*
         * Scaling - we cannot use scale directly as it miscalculates popup position on screen
         *           therefore we have to update scale for each element
         *           also we must keep track of both widthScale and heigtScale for layout changes
         */
        property real contentScale: Math.min( root.widthScale, root.heightScale ) * 0.90
        property real widthScale: root.widthScale
        property real heightScale: root.heightScale
        onWidthScaleChanged: column.width = root.width / column.contentScale;
        onHeightScaleChanged: column.width = root.width / column.contentScale;

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
                text: help.title
                font.bold: true
                style: Text.Raised
                styleColor: '#000000'
                color: 'white'
                //wrapMode: Text.WordWrap
                width: column.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        /*Item {
            width: 8
            height: 4
        }*/

        Text {
            id: help_desc0
            font.pixelSize: Math.round( 20 * column.contentScale )
            text: root.strings[root.locale]['help_desc0']
            font.bold: true
            style: Text.Raised
            styleColor: '#000000'
            color: 'white'
            width: column.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        LetterRow {
            word: root.strings[root.locale]['help_word0']
            demo: true
            size: Math.round( 48 * column.contentScale )

            Component.onCompleted: {
                setState( 2, 'correct' );
            }
        }

        Text {
            font.pixelSize: Math.round( 18 * column.contentScale )
            text: root.strings[root.locale]['help_desc1']
            font.bold: true
            style: Text.Raised
            styleColor: '#000000'
            color: 'white'
            width: column.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        LetterRow {
            word: root.strings[root.locale]['help_word1']
            demo: true
            size: Math.round( 48 * column.contentScale )

            Component.onCompleted: {
                setState( 1, 'outOfPlace' );
            }
        }

        Text {
            font.pixelSize: Math.round( 18 * column.contentScale )
            text: root.strings[root.locale]['help_desc2']
            font.bold: true
            style: Text.Raised
            styleColor: '#000000'
            color: 'white'
            width: column.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        LetterRow {
            word: root.strings[root.locale]['help_word2']
            demo: true
            size: Math.round( 48 * column.contentScale )

            Component.onCompleted: {
                setState( 0, 'incorrect' );
            }
        }

        Text {
            font.pixelSize: Math.round( 18 * column.contentScale )
            text: root.strings[root.locale]['help_desc3']
            font.bold: true
            style: Text.Raised
            styleColor: '#000000'
            color: 'white'
            width: column.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        LetterRow {
            id: badWord
            word: root.strings[root.locale]['help_word3']
            demo: true
            size: Math.round( 48 * column.contentScale )

            // FIXME: state changes when switching locales
            //        with different word lengths
            Component.onCompleted: {
                for ( var y = 0; y < badWord.word.length; y++ )
                    badWord.setState( y, 'badword' );
            }
        }

        Text {
            font.pixelSize: Math.round( 18 * column.contentScale )
            text: root.strings[root.locale]['help_desc4']
            font.bold: true
            style: Text.Raised
            styleColor: '#000000'
            color: 'white'
            width: column.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        ColourButton {
            color: 'white'
            text: root.strings[root.locale]['close']
            onClicked: { help.close(); }
            textColor: 'black'
            styleColor: 'white'
            fontPixelSize: Math.round( 28 * column.contentScale )
        }

        // padding
        Item {
            width: 1
            height: root.banner.height
        }
    }

    onClosed: {
        // restore text input focus (it sometimes looses focus for no reason)
        if ( root.os !== 'android' )
            root.textInput.focus = true;
    }
}
