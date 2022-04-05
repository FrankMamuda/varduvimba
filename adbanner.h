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
#include <QQuickItem>
#ifdef Q_OS_ANDROID
#include <QJniObject>
#endif

/**
 * @brief The AdView class
 */
class AdBanner : public QQuickItem {
    Q_PROPERTY( QString adMobId READ adMobId WRITE setAdMobId )
    Q_OBJECT

public:
    explicit AdBanner( QQuickItem *parent = nullptr );

#ifdef Q_OS_ANDROID
    ~AdBanner() override;
#endif

    QString adMobId() const { return this->m_adMobId; }

public slots:
#ifdef Q_OS_ANDROID
    void setAdMobId( const QString &id );
    void show();
    void hide();
    void repaint();

private slots:
    void setup();
    void updatePos();
#else
    void setAdMobId( const QString & ) {}
#endif

private:
   QString m_adMobId;
#ifdef Q_OS_ANDROID
   const QJniObject adBanner;
#endif
};
