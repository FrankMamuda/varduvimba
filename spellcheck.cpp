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
 * includes
 */
#include "spellcheck.h"
#include <hunspell/hunspell.hxx>
#include <QFile>
#include <QDebug>
#include <QRandomGenerator>
#include <QFileInfo>
#include <QSettings>

/**
 * @brief SpellCheck::SpellCheck
 * @param path
 * @param fileName
 */
SpellCheck::SpellCheck( const QString &path, const QString &fileName ) {
    // initialize hunspell
    this->hunspell = new Hunspell( QString( path + fileName + ".aff" ).toLocal8Bit().constData(), QString( path + fileName + ".dic" ).toLocal8Bit().constData());

    // retrieve user added words from settings
    this->customWords = QSettings().value( "customWords" ).toStringList();
    for ( const QString &word : this->customWords ) {
        if ( word.isEmpty())
            continue;

        this->hunspell->add( word.toStdString());
    }

    // get base word list from the dictionary file
    QFile file( QString( path + fileName + ".dic" ));
    if ( file.open( QIODevice::ReadOnly )) {

        while ( !file.atEnd()) {
            const QString line = QString::fromUtf8( file.readLine().constData());
            const qsizetype index = line.indexOf( "/" );
            const QString word = index > 0 ? line.left( index ) : line;

            if ( word.isEmpty())
                continue;

            if ( !word.at( 0 ).isLetter())
                continue;

            if ( word.at( 0 ).isUpper())
                continue;

            this->words << word;
        }

        file.close();
    }
}

/**
 * @brief SpellCheck::~SpellCheck
 */
SpellCheck::~SpellCheck() {
    delete this->hunspell;
}

/**
 * @brief SpellCheck::isValid
 * @param word
 * @return
 */
bool SpellCheck::isValid( const QString &word ) const {
    // use hunspell to check spelling
    return this->hunspell->spell( word.toStdString());
}

/**
 * @brief SpellCheck::generateRandomWord
 * @return
 */
QString SpellCheck::generateRandomWord( int length ) const {
    QString out;

    // NOTE: here's how it works
    //       1) pick a random word from the dictionary
    //       2) use hunspell to generate suggestions for the word
    //       3) pick a random word from the suggestions with the required length
    forever {
        const qsizetype index = QRandomGenerator::global()->bounded( this->words.count());
        const QString baseWord( this->words.at( index ));
        std::vector<std::string> generated = this->hunspell->suggest( baseWord.toStdString());

        QStringList list;
        if ( baseWord.length() == length )
            list << baseWord;

        for ( auto &w : generated ) {
           const QString word = QString::fromStdString( w );
           if ( word.length() == length )
               list << word;
        }

        if ( !list.isEmpty()) {
            out = list.at( QRandomGenerator::global()->bounded( list.count()));
            break;
        }

        if ( !out.isEmpty())
            break;
    }

    return out.toUpper();
}

/**
 * @brief SpellCheck::addWord
 * @param word
 */
void SpellCheck::addWord( const QString &word ) {
    // TODO: perform proper validation
    if ( word.isEmpty())
        return;

    if ( !word.at( 0 ).isLetter())
        return;

    this->customWords.append( word );
    QSettings().setValue( "customWords", this->customWords );
    this->hunspell->add( word.toStdString());
}
