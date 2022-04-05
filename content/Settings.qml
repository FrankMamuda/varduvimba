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
    id: settings
    anchors.centerIn: parent
    modal: true
    property string title: 'Uzstādījumi'

    background: Rectangle {
        color: 'transparent'
    }

    Overlay.modal: Rectangle {
        color: '#aa000000'
    }

    contentItem: Column {
        id: column
        anchors.centerIn: parent
        spacing: 16
        scale: Math.max( 1.0, Math.min( root.widthScale, root.heightScale ))

        Component.onCompleted: {
            for ( let item in children )
                children[item].anchors.horizontalCenter = column.horizontalCenter;
        }

        Item {
            height: header.height + 16
            width: header.width

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                color: root.palette['activeBorder']
                opacity: .4
                width: root.width / column.scale
                height: header.height + 16
            }

            Text {
                id: header
                font.pixelSize: 34
                anchors.centerIn: parent
                text: settings.title
                font.bold: true
                style: Text.Raised
                styleColor: '#000000'
                color: 'white'
                wrapMode: Text.WordWrap
                width: column.width
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item {
            width: 8
            height: 12
        }

        Spinner {
            id: letters
            anchors.horizontalCenter: column.horizontalCenter
            value: root.initialLength
            text: 'Burtu skaits'
            min: 4
            max: 10
        }

        Spinner {
            id: guesses
            anchors.horizontalCenter: column.horizontalCenter
            value: root.initialRows
            text: 'Minējumu skaits'
            min: 4
            max: 10
        }

        Spinner {
            anchors.horizontalCenter: column.horizontalCenter
            value: root.keyboard.mode
            text: 'Klaviatūra'
            textMode: true
            textValues: [ "kompakta", "3-rindu", "4-rindu" ]
            min: 0
            max: 2

            // this can be done instantly, because reset is not required
            onValueChanged: {
                if ( settings.visible ) {
                    root.keyboard.mode = value;
                    root.save();
                }
            }
        }

        NamedSwitch {
            anchors.horizontalCenter: column.horizontalCenter
            text: 'Tumšais režīms'
            checked: root.darkMode

            onClicked: {
                root.darkMode = !root.darkMode;
                root.save();
            }
        }

        /*
        NamedSwitch {
            anchors.horizontalCenter: column.horizontalCenter
            text: 'Tikai vārdnīcas vārdi'
            checked: root.darkMode
        }*/

        Item {
            width: 1
            height: 16
        }

        ColourButton {
            color: 'white'
            text: 'Aizvērt'
            onClicked: { settings.close(); }
            textColor: 'black'
            styleColor: 'white'
        }
    }

    onClosed: {
        // hide settings dialog
        settings.visible = false;

        // restore text input focus (it sometimes looses focus for no reason)
        if ( root.os !== 'android' )
            root.textInput.focus = true;

        // since reset is rather expensive, do it only once or
        // don't do it at all if not needed
        let reset = false;

        // handle guesses
        if ( guesses.value !== root.initialRows ) {
            reset = guesses.value <= root.currentRow;
            root.initialRows = guesses.value;

            if ( reset )
                console.log( 'Reset due to rows' );
            else {
                console.log( 'Soft reset due to rows' );

                //
                // this is ugly, but it works
                //
                var state;
                try {
                    state = JSON.parse( root.settings.get( "state" ));
                } catch ( exception ) {
                    root.reset();
                    return;
                }

                state.r = guesses.value;
                root.settings.set( "state", JSON.stringify( state ));
                root.load();
            }
        }

        // handle letters
        if ( letters.value !== root.initialLength ) {
            reset = true;
            root.initialLength = letters.value;

            console.log( 'Reset due to letters' );
        }

        if ( reset )
            root.reset( true );

        root.save();
    }
}
