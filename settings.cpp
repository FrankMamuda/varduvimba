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
#include "settings.h"

/**
 * @brief Settings::set
 * @param key
 * @param value
 */
void Settings::set( const QString &key, const QVariant &value ) {
    QSettings().setValue( key, value );
}

/**
 * @brief Settings::get
 * @param key
 * @param defaultValue
 * @return
 */
QVariant Settings::get( const QString &key, const QVariant &defaultValue ) {
    return QSettings().value( key, defaultValue );
}

/**
 * @brief Settings::isEnabled
 * @param key
 * @param defaultValue
 * @return
 */
bool Settings::isEnabled( const QString &key, bool defaultValue ) {
    // NOTE: get( key ) method returns QVariant which is a JS object
    //       not a boolean
    //       use isEnabled( key ) to get a proper boolean
    return QSettings().value( key, defaultValue ).toBool();
}
