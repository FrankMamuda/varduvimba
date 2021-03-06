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
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include <QDir>
#include <QDir>
#include <QStandardPaths>
#include <QIcon>
#include "settings.h"
#include "spellcheck.h"
#include "adbanner.h"
#ifdef Q_OS_ANDROID
#include "hapticfeedback.h"
#endif

/**
 * @brief qMain
 * @param argc
 * @param argv
 * @return
 */
int main( int argc, char *argv[] ) {
    QCoreApplication::setOrganizationName( "factory12" );
    QCoreApplication::setOrganizationDomain( "factory12.org" );
    QCoreApplication::setApplicationName( "vardotajs" );

    QGuiApplication app( argc, argv );

#ifndef Q_OS_ANDROID
    app.setWindowIcon( QIcon( ":/icons/icon.png" ));
#endif

    // register ad component
    qmlRegisterType<AdBanner>( "AdBanner", 1, 0, "AdBanner" );

    QQmlApplicationEngine engine;
    const QUrl url( "qrc:/main.qml" );
    QObject::connect( &engine, &QQmlApplicationEngine::objectCreated, &app, [ url ]( QObject *obj, const QUrl &objUrl ) {
        if ( obj == nullptr && url == objUrl )
            QCoreApplication::exit( -1 );
    }, Qt::QueuedConnection );

    // get dictionary files
    // NOTE: use a different locale for other languages
    const QString sourcePath( "://dictionary/" );
#ifdef Q_OS_ANDROID
    const QString destinationPath( QStandardPaths::writableLocation( QStandardPaths::AppDataLocation ) + "/" );
#else
    const QString destinationPath( QDir::currentPath() + "/" );
#endif


    // TODO: check size and force copy if it differs
    auto copyLocale = [ sourcePath, destinationPath ]( const QString &locale ) {
        const QString affd( destinationPath + locale + ".aff" );
        const QString dicd( destinationPath + locale + ".dic" );
        const QString affs( sourcePath + locale + ".aff" );
        const QString dics( sourcePath + locale + ".dic" );

        if ( !QFileInfo::exists( affd ))
            QFile::copy( affs, affd );

        if ( !QFileInfo::exists( dicd ))
            QFile::copy( dics, dicd );
    };
    copyLocale( "en_US" );
    copyLocale( "lv_LV" );

    // initialize cpp objects for use in QML
    SpellCheck spellCheck;
    Settings settings;
#ifdef Q_OS_ANDROID
    HapticFeedback hapticFeedback;
#endif

    //qDebug() << "System locale is" << QLocale::system().name();

    // set cpp objects as QML properties
    engine.setInitialProperties( {
                                     { "spellCheck", QVariant::fromValue( &spellCheck ) },

                                 #ifdef Q_OS_ANDROID
                                     { "os", "android" },
                                     { "hapticFeedback", QVariant::fromValue( &hapticFeedback ) },
                                 #endif

                                     { "path", destinationPath },
                                     { "locale", QLocale::system().name() },

                                 #ifdef PRODUCTION_RELEASE
                                     { "production", true },
                                     { "adMobId", "####use_your_own_id####" },
                                 #else
                                     { "production", false },
                                 #endif

                                     { "settings", QVariant::fromValue( &settings ) },

                                 } );

    // load QML engine
    engine.load( url );
    return app.exec();
}
