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
 * save - save game state
 */
function save() {
    var state = {};

    // save internal state
    state.u = root.usedWords;
    state.l = root.word.length;
    state.g = root.gameOver;
    state.w = root.word;
    state.c = root.currentString;
    state.r = root.initialRows;
    state.k = root.keyboard.mode;
    state.z = root.lost;
    state.d = root.darkMode;
    state.x = root.locale;

    // save in external string
    root.settings.set( "state", JSON.stringify( state ));
}

/*
 * reset
 */
function reset( reinitialize = true ) {
    if ( reinitialize )
        root.word = root.spellCheck.generateRandomWord( root.initialLength )

    // announce
    console.log( 'Hello wordl: ' + root.word )

    // reset internal state
    root.badWord = false;
    root.usedLetters = '';
    root.correctLetters = '';
    root.currentString = '';
    root.currentRow = 0;
    root.usedWords = [];
    root.gameOver = false;
    root.initialLength = root.word.length;
    root.lost = false;

    if ( root.locale !== 'lv_LV' )
        root.keyboard.mode = 1;

    if ( reinitialize )
        root.save();

    if ( root.os !== 'android' )
        root.textInput.focus = true;
}

/*
 * load - load game state
 */
function load() {
    var state;

    try {
        state = JSON.parse( root.settings.get( "state" ));
    } catch ( exception ) {
        console.log( 'Load spellcheck (initial)' );

        if ( root.locales.indexOf( root.locale ) === -1 )
            root.locale = root.locales[0]; // default to en_US

        root.spellCheck.initialize( root.path, root.locale )

        root.reset();


        help.open();

        return;
    }

    // temporarily disable animations
    root.animationsDisabled = true;

    // restore state
    root.word = state.w === undefined ? '' : state.w;
    root.reset( false );
    root.initialRows = state.r === undefined ? 6 : state.r;
    root.keyboard.mode = state.k === undefined ? 1 : state.k;
    root.darkMode = state.d === undefined ? true : state.d;

    // revert to default system locale
    root.locale = state.x === undefined ? root.locale : state.x;
    if ( root.locales.indexOf( root.locale ) === -1 )
        root.locale = root.locales[0]; // default to en_US

    console.log( 'Load spellcheck' );
    root.spellCheck.initialize( root.path, root.locale )

    // restore used words (simulate key press)
    let y;
    for ( y = 0; y < state.u.length; y++ ) {
        const w = state.u[y];
        console.log( 'Process: ' + w );
        for ( let k = 0; k < w.length; k++ ) {
            root.press( w[k] );
        }
        root.press( '1' );
    }

    // restore current string (simulate key press)
    for ( y = 0; y < state.c.length; y++ )
        root.press( state.c[y] );

    // reenable animations
    root.animationsDisabled = false;

    root.lost = state.z === undefined ? false : state.z;
    root.gameOver = state.g === undefined ? 0 : state.g;
}

/*
 * setupAds
 */
function setupAds() {
    if ( root.os !== 'android' )
        return;

    const enabled = root.settings.isEnabled( 'advertisments', true );
    if ( !enabled ) {
        root.banner.hide();
        root.banner.visible = false;
        root.banner.height = 0;
        root.keyboardRect.anchors.bottom = canvas.bottom;
    } else {
        root.banner.visible = true;
        root.banner.show();
        root.keyboardRect.anchors.bottom = root.banner.parent.top;
    }
}

/*
 * simulate key press
 */
function press( keyLetter ) {
    // reset badWord state
    root.badWord = false;

    // validate letter
    const letters = root.locale === 'lv_LV' ? /[ĀEĒRTUŪIĪOPĻASŠDFGĢHJKĶLZŽCČVBNŅM01]/i : /[QWERTYUIOPASDFGHJKLZXCVBNM01]/i;
    if ( !keyLetter.match( letters ))
        return;

    // get current row
    const currentRow = letterRows.itemAt( root.currentRow );

    if ( !root.gameOver ) {
        //
        // 0 - virtual backspace key
        //
        if ( keyLetter === '0' ) {
            // remove last letter
            if ( root.currentString.length > 0 )
                root.currentString = root.currentString.slice( 0, root.currentString.length - 1 );

            // restore letter state to 'inactive'
            // (used when a bad (non-dictionary) word is entered
            for ( let i = 0; i < root.word.length; i++ )
                currentRow.letters.itemAt( i ).letter.state = 'inactive';

            // we're done here
            return;
        }

        //
        // 1 - virtual return/enter key
        //
        if ( keyLetter === '1' ) {
            // only works when the row is full of lettes
            if ( root.currentString.length === root.word.length ) {
                // ad enabler/disabler
                if ( root.currentString === root.strings[root.locale]['ads_no'] ) {
                    console.log( 'Disable ads' );
                    root.settings.set( 'advertisments', false );
                }

                if ( root.currentString === root.strings[root.locale]['ads_yes'] ) {
                    console.log( 'Enable ads' );
                    root.settings.set( 'advertisments', true );
                }

                // validate word
                if ( !root.spellCheck.isValid( root.currentString )) {
                    console.log( 'Invalid word: ' + root.currentString );

                    // disable for now
                    //root.badWord = true;

                    // word is not valid - mark it as red
                    for ( let i = 0; i < root.word.length; i++ )
                        currentRow.letters.itemAt( i ).letter.state = 'badword';

                    return;
                }

                if ( root.currentRow < letterRows.count ) {
                    // store used words/rows
                    root.usedWords.push( root.currentString );

                    const word = root.word;

                    let i;

                    // compare current row to the game word
                    let correct = {};
                    let letters = {};
                    let recheck = [];

                    // first find correct and incorrect letters
                    for ( i = 0; i < root.word.length; i++ ) {
                        const l = word[i];
                        if ( !( l in letters ))
                            letters[l] = 1;
                        else
                            letters[l]++;

                        const c = root.currentString[i];

                        if ( root.usedLetters.indexOf( c ) === -1 )
                            root.usedLetters += c;

                        if ( word.indexOf( c ) === -1 ) {
                            currentRow.letters.itemAt( i ).letter.state = 'incorrect';
                            continue;
                        }

                        if ( l === c ) {
                            if ( !( c in correct ))
                                correct[c] = 1;
                            else
                                correct[c]++;

                            if ( root.correctLetters.indexOf( c ) === -1 )
                                root.correctLetters += c;

                            currentRow.letters.itemAt( i ).letter.state = 'correct';
                            continue;
                        }

                        recheck.push( i );
                    }

                    // then check for letters out of place
                    for ( i = 0; i < recheck.length; i++ ) {
                        const r = recheck[i];
                        const l = root.currentString[r];
                        const cc = ( l in correct ) ? correct[l] : 0;
                        const tc = ( l in letters ) ? letters[l] : 0;

                        if ( cc === tc )
                            currentRow.letters.itemAt( r ).letter.state = 'incorrect';
                        else {
                            currentRow.letters.itemAt( r ).letter.state = 'outOfPlace';
                            letters[l] = Math.max( 0, letters[l] - 1 );
                        }
                    }

                    root.lastRow = root.currentRow;

                    // if words match - game is over
                    if ( root.currentString === root.word ) {
                        root.gameOver = true;

                        // announce
                        console.log( 'Game over' );
                        return;
                    }

                    // advance one row
                    root.currentString = '';
                    root.currentRow += 1;

                    if ( root.currentRow >= letterRows.count ) {
                        for ( let k = 0; k < root.word.length; k++ )
                            letterRows.itemAt( root.currentRow - 1 ).letters.itemAt( k ).letter.state = 'badword';

                        root.gameOver = true;
                        root.lost = true;
                        console.log( 'Game over, sucker!' );

                        root.save();
                    }
                }
            }

            // we're done here
            return;
        }

        // add a single letter to current row
        if ( root.currentString.length < root.word.length )
            root.currentString += keyLetter;
    }
}

/*
 * resetRows
 */
function resetRows() {
    root.reset();

    for ( let y = 0; y < letterRows.count; y++ )
        letterRows.itemAt( y ).reset();
}
