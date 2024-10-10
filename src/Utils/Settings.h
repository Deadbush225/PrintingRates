#ifndef SETTINGS_H
#define SETTINGS_H

#include <QString>
#include <QSettings>
#include <QList>

#include "ModQMap.h"

class ModQSettings : public QSettings {
public:
    using QSettings::QSettings;
    using QSettings::value;

    template <typename T>
    T value(const QString& key, const QVariant& defaultValue);
};


template <typename T>
class ModQList : public QList<T> {
public:
    ModQList() {};
    ModQList(std::initializer_list<T> list) : QList<T>(list) {}
    QString toString();
    static ModQList<int> fromString(const QString& string);
};


class Settings
{
private:
    ModQSettings* settings;

public:
    Settings();
    ModQList<int> CT_Photo;
    ModQList<int> CT_Text;
    ModQList<int> CT_TextWPhoto;

    QStringList PC_Options;

    ModQMap<QString, ModQList<int>> contentType_Map = {};
    // QProperty<QMap<QString, QList<int>>> contentType_Map;
    QStringList photoCoverage_Options;
    ModQMap<QString, double> qualityType_Map;
    ModQMap<QString, double> paperSize_Map;
    ModQMap<QString, int> paperType_Map;
};

// Specialization for QString
template <>
ModQList<int> ModQList<QString>::fromString(const QString &string);

#endif // SETTINGS_H
