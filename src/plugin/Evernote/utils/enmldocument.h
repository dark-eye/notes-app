/*
 * Copyright: 2013 Canonical, Ltd
 *
 * This file is part of reminders-app
 *
 * reminders-app is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef ENMLDOCUMENT_H
#define ENMLDOCUMENT_H

#include <QString>

class EnmlDocument
{
public:
    EnmlDocument(const QString &enml = QString());

    QString enml() const;
    void setEnml(const QString &enml);

    // noteGuid is required to convert en-media tags to urls for image provider
    QString html(const QString &noteGuid) const;
    void setHtml(const QString &html);

    QString plaintext() const;

private:
    QString m_enml;

    static QStringList s_commonTags;
    static QStringList s_argumentBlackListTags;

};

#endif // ENMLDOCUMENT_H
