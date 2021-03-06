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

#pragma once

/*
 * includes
 */
#include <QObject>
#include <QString>
#include <QStringList>

/*
 * classes
 */
class Hunspell;

/**
 * @brief The SpellCheck class
 */
class SpellCheck : public QObject {
    Q_OBJECT

public:
    explicit SpellCheck();
    ~SpellCheck() override;
    Q_INVOKABLE void initialize( const QString &path, const QString &fileName );
    Q_INVOKABLE bool isValid( const QString &word ) const;
    Q_INVOKABLE QString generateRandomWord( int length = 5 ) const;
    Q_INVOKABLE void addWord( const QString &word );

private:
    Hunspell *hunspell = nullptr;
    QStringList words;
    QStringList customWords;
    QString locale;
};
