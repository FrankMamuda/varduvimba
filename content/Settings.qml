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
    property string title: root.strings[root.locale]['settings']
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
        spacing: Math.round( 16 * column.contentScale );
        width: root.width / column.contentScale;

        /*
         * Scaling - we cannot use scale directly as it miscalculates popup position on screen
         *           therefore we have to update scale for each element
         *           also we must keep track of both widthScale and heigtScale for layout changes
         */
        property real contentScale: Math.min( root.widthScale, root.heightScale )
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
                width: root.width / column.scale
                height: Math.round( header.height + 16 * column.contentScale )
            }

            Text {
                id: header
                font.pixelSize: Math.round( 34 * column.contentScale )
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
            width: 1
            height: Math.round( 12 * column.contentScale )
        }

        Spinner {
            id: letters
            anchors.horizontalCenter: column.horizontalCenter
            value: root.initialLength
            text: root.strings[root.locale]['letters']
            min: 4
            max: 10
            contentScale: column.contentScale
        }

        Spinner {
            id: guesses
            anchors.horizontalCenter: column.horizontalCenter
            value: root.initialRows
            text: root.strings[root.locale]['guesses']
            min: 4
            max: 10
            contentScale: column.contentScale
        }

        Spinner {
            visible: root.locale === 'lv_LV'
            anchors.horizontalCenter: column.horizontalCenter
            value: root.keyboard.mode
            text: 'Klaviatūra'
            textMode: true
            textValues: [ "kompakta", "3-rindu", "4-rindu" ]
            min: 0
            max: 2
            contentScale: column.contentScale

            // this can be done instantly, because reset is not required
            onValueChanged: {
                if ( settings.visible ) {
                    root.keyboard.mode = value;
                    root.save();
                }
            }
        }

        Spinner {
            anchors.horizontalCenter: column.horizontalCenter
            value: locales.indexOf( root.locale ) === -1 ? 0 : locales.indexOf( root.locale )
            text: root.strings[root.locale]['language']
            textMode: true
            textValues: [ root.strings[root.locale]['latvian'], root.strings[root.locale]['english'] ]
            min: 0
            max: 1
            property var locales: [ 'lv_LV', 'en_US' ]
            contentScale: column.contentScale

            onValueChanged: {
                if ( settings.visible ) {
                    // set new locale and reinitialize spellCheck
                    root.locale = locales[value];
                    root.spellCheck.initialize( root.path, root.locale )
                    root.word = '';

                    // reset view
                    root.reset( true );

                    // save state
                    root.save();
                }
            }
        }

        NamedSwitch {
            anchors.horizontalCenter: column.horizontalCenter
            text: root.strings[root.locale]['dark']
            checked: root.darkMode
            contentScale: column.contentScale

            onClicked: {
                root.darkMode = !root.darkMode;
                root.save();
            }
        }

        // swap keys Switch
        NamedSwitch {
            anchors.horizontalCenter: column.horizontalCenter
            text: root.strings[root.locale]['swap']
            checked: root.swap
            contentScale: column.contentScale

            onClicked: {
                root.swap = !root.swap;
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
            height: Math.round( 2 * column.contentScale )
        }

        ColourButton {
            color: 'white'
            text: root.strings[root.locale]['close']
            onClicked: { settings.close(); }
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
