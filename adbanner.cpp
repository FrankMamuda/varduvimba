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
#include "adbanner.h"
#include <QGuiApplication>
#include <QQuickWindow>

/**
 * @brief AdBanner::AdBanner
 * @param parent
 */
AdBanner::AdBanner( QQuickItem *parent ) : QQuickItem( parent )
  #ifdef Q_OS_ANDROID
  , adBanner( "org/factory12/vardotajs/AdBanner", "(Landroid/app/Activity;)V", QNativeInterface::QAndroidApplication::context())
  #endif
{
#ifdef Q_OS_ANDROID
    QScreen::connect( qApp->primaryScreen(), &QScreen::geometryChanged, this, &AdBanner::repaint );
    QGuiApplication::connect( qApp, &QGuiApplication::applicationStateChanged, this, [ this ]( Qt::ApplicationState state ) {
        this->adBanner.callMethod<void>( state == Qt::ApplicationActive ? "start" : "stop" );
    } );

    QQuickItem::connect( this, &QQuickItem::xChanged, this, [ this ]() { this->updatePos(); } );
    QQuickItem::connect( this, &QQuickItem::yChanged, this, [ this ]() { this->updatePos(); } );

    if ( !this->adBanner.isValid())
        return;

    this->adBanner.callMethod<void>( "create" );
    this->setup();
#endif
}

#ifdef Q_OS_ANDROID
/**
 * @brief AdBanner::~AdBanner
 */
AdBanner::~AdBanner() {
    this->adBanner.callMethod<void>( "destroy" );
}

/**
 * @brief AdBanner::setAdMobId
 * @param id
 */
void AdBanner::setAdMobId( const QString &id ) {
    if ( !this->adBanner.isValid())
        return;

    this->m_adMobId = id;
    this->adBanner.callMethod<void>( "setId", "(Ljava/lang/String;)V", QJniObject::fromString( this->adMobId()).object<jstring>());
}

/**
 * @brief AdBanner::show
 */
void AdBanner::show() {
    if ( !this->adBanner.isValid() || this->adMobId().isEmpty())
        return;

    this->updatePos();
    this->adBanner.callMethod<void>( "show" );
}

/**
 * @brief AdBanner::hide
 */
void AdBanner::hide() {
    if ( !this->adBanner.isValid())
        return;

    this->adBanner.callMethod<void>( "hide" );
}

/**
 * @brief AdBanner::repaint
 */
void AdBanner::repaint() {
    if ( !this->adBanner.isValid())
        return;

    this->hide();
    this->adBanner.callMethod<void>( "update" );
    this->setup();
    this->setAdMobId( this->adMobId());
    this->show();
}

/**
 * @brief AdBanner::setup
 */
void AdBanner::setup() {
    if ( !this->adBanner.isValid())
        return;

    this->adBanner.callMethod<void>( "setup" );
    this->setWidth( static_cast<qreal>( this->adBanner.callMethod<jint>( "width" )) / qApp->primaryScreen()->devicePixelRatio());
    this->setHeight( static_cast<qreal>( this->adBanner.callMethod<jint>( "height" )) / qApp->primaryScreen()->devicePixelRatio());
}

/**
 * @brief AdBanner::updatePos
 */
void AdBanner::updatePos() {
    if ( !this->adBanner.isValid())
        return;

    const qreal devicePixelRatio = qApp->primaryScreen()->devicePixelRatio();
    const QPointF pos = mapToGlobal( QPointF( 0, 0 ));
    const int x = static_cast<int>( pos.x() * devicePixelRatio );
    const int y = static_cast<int>( pos.y() * devicePixelRatio );

    this->adBanner.callMethod<void>( "setPos", "(II)V", x, y );
}
#endif
