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
SpellCheck::SpellCheck() {}

/**
 * @brief SpellCheck::~SpellCheck
 */
SpellCheck::~SpellCheck() {
    delete this->hunspell;
}

/**
 * @brief SpellCheck::initialize
 * @param path
 * @param fileName
 */
void SpellCheck::initialize( const QString &path, const QString &fileName ) {
    //qDebug() << "Request spellcheck" << fileName << this->locale;

    // no need to reinitialize if locales match
    if ( !QString::compare( this->locale, fileName ))
        return;

    // announce
    qDebug() << "Initialize spellcheck" << fileName;

    // clear initial words
    this->words.clear();
    this->customWords.clear();

    // save locale
    this->locale = fileName;

    if ( this->hunspell != nullptr )
        delete this->hunspell;

    // initialize hunspell
    this->hunspell = new Hunspell( QString( path + fileName + ".aff" ).toLocal8Bit().constData(), QString( path + fileName + ".dic" ).toLocal8Bit().constData());

    // retrieve user added words from settings
    this->customWords = QSettings().value( "customWords_" + this->locale ).toStringList();
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
 * @brief SpellCheck::isValid
 * @param word
 * @return
 */
bool SpellCheck::isValid( const QString &word ) const {
    // use hunspell to check spelling
    return this->hunspell->spell( word.toLower().toStdString());
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

    // TODO: proper A-Z validation

    forever {
        const qsizetype index = QRandomGenerator::global()->bounded( this->words.count());
        const QString baseWord( this->words.at( index ));

        if ( baseWord.contains( "'" ) || baseWord.contains( " " ))
            continue;

        std::vector<std::string> generated = this->hunspell->suggest( baseWord.toStdString());

        QStringList list;
        if ( baseWord.length() == length )
            list << baseWord;


        /*QString expression;
        if ( !QString::compare( this->locale, "lv_LV" ))
            expression = QString( "[QWERTYUIOPASDFGHJKLZXCVBNM]{%1}" ).arg( length ).toLower();
        if ( !QString::compare( this->locale, "en_US" ))
            expression = QString( "[ĀEĒRTUŪIĪOPĻASŠDFGĢHJKĶLZŽCČVBNŅM]{%1}" ).arg( length ).toLower();

        const QRegularExpression rx( expression, QRegularExpression::CaseInsensitiveOption );
        const QRegularExpressionValidator validator( rx );*/

        // FIXME: ignore invalid word "kažok"

        for ( auto &w : generated ) {
           QString word = QString::fromStdString( w );
           //int pos = 0;

           if ( word.simplified().length() != length ) {
               //qDebug() << "ignore bad length word" << word;
               continue;
           }

           if ( word.contains( "'" ) || word.contains( " " )) {
               qDebug() << "ignore hypenated or spaced word" << word << this->locale;
               continue;
           }

           /*if ( validator.validate( word, pos ) != QValidator::Acceptable ) {
               qDebug() << "ignore invalid word" << word << this->locale;
               continue;
           }*/

           // this works better than validator
           bool badWord = false;
           for ( QChar ch : word ) {
               if ( !ch.isLetter()) {
                    qDebug() << "ignore invalid word" << word << this->locale;
                    badWord = true;
                    break;
               }
           }


           if ( badWord )
               continue;

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
void SpellCheck::addWord( const QString &w ) {
    const QString word( w.toLower());

    // TODO: perform proper validation
    if ( word.isEmpty())
        return;

    if ( !word.at( 0 ).isLetter())
        return;

    if ( this->customWords.contains( word ))
        return;

    this->customWords.append( word );
    this->customWords.removeDuplicates();

    QSettings().setValue( "customWords_" + this->locale, this->customWords );
    this->hunspell->add( word.toStdString());
}
