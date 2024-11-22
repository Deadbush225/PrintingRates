#ifndef SETTINGS_H
#define SETTINGS_H

#include <QList>
#include <QSettings>
#include <QString>

#include <QMetaType>

#include <QCoreApplication>
#include <QIODevice>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSettings>
#include <QVariant>

#include "ModOrderedMap.h"
#include "ModQMap.h"

// using QVarMap = std::variant<QVariant, QMap<QString, QVariant>>;

// class

template <typename T>
class ModQList : public QList<T> {
   public:
    ModQList() {};
    ModQList(std::initializer_list<T> list) : QList<T>(list) {}
    QString toString();
    static ModQList<int> fromString(const QString& string);

    // Conversion operator to QVariant
    operator QVariant() const { return QVariant::fromValue(*this); }
};

Q_DECLARE_METATYPE(ModQList<int>);

// QDataStream& operator<<(QDataStream& out, const ModQList<int>& list) {
//     out << static_cast<const QList<int>&>(list);
//     return out;
// }

// QDataStream& operator>>(QDataStream& in, ModQList<int>& list) {
//     in >> static_cast<QList<int>&>(list);
//     return in;
// }

bool readJsonFile(QIODevice& device, QSettings::SettingsMap& map);
bool writeJsonFile(QIODevice& device, const QSettings::SettingsMap& map);

QList<QVariant> convertToQVariantList(const QList<int>& intList);

const QSettings::Format JsonFormat =
    QSettings::registerFormat("json", readJsonFile, writeJsonFile);

class ModQSettings : public QSettings {
   public:
    ModQSettings()
        : QSettings(QCoreApplication::applicationDirPath() + "/config.json",
                    JsonFormat) {}

    using QSettings::value;

    class Proxy {
       public:
        Proxy(const QVariant& var)
            : var(var), cachedMap(nullptr), cachedList(nullptr) {}

        Proxy operator[](QString key) const {
            // if (var.canConvert<QVariantMap>()) {
            if (var.typeId() == QVariant::Map) {
                if (!cachedMap) {
                    cachedMap = new QVariantMap(var.toMap());
                }

                qDebug() << "CAN CONVERT TO QVARIANT MAP";
                qDebug() << key;
                // QMap<QString, QVariant> map = var.toMap();
                return Proxy(cachedMap->value(key));
            }
            return Proxy(QVariant());
        }

        Proxy operator[](int index) {
            if (var.typeId() == QVariant::String) {
                // if (!cachedList) {
                cachedList = new QVariantList(var.toList());
                // cachedList = new QVariantList(var.toList());
                // }

                if (index >= 0 && index < cachedList->size()) {
                    qDebug() << "validIndex";
                    qDebug() << var;
                    qDebug() << index << " as "
                             << cachedList->toList().at(index).toInt();
                    return Proxy(cachedList->at(index));
                }
            }
        }

        template <typename T>
        Proxy operator[](int index) {
            if (var.type() == QVariant::String) {
                if (!cachedList) {
                    cachedList = new QVariantList(
                        convertToQVariantList(static_cast<QList<T>>(
                            ModQList<QString>::fromString(var.toString()))));
                    // cachedList = new QVariantList(var.toList());
                }

                if (index >= 0 && index < cachedList->size()) {
                    qDebug() << "validIndex TEMPLATE";
                    qDebug()
                        << index << " as " << cachedList->at(index).toInt();
                    qDebug() << cachedList->at(index).toInt();

                    return Proxy(cachedList->at(index));
                }
            }
        }

        QStringList keys() { return var.toMap().keys(); }

        QStringList items() { return var.toStringList(); }

        template <typename T>
        Proxy& operator=(const T& value) {
            var = QVariant::fromValue(value);
            return *this;
        }

        QVariant toVariant() { return var; }

        operator QString() const { return var.toString(); }

        operator QVariant() const { return var; }

        operator QMap<QString, QVariant>() const { return var.toMap(); }

        // template <typename T>
        operator QMap<QString, QList<int>>() const {
            return var.value<QMap<QString, QList<int>>>();
        }

        template <typename T>
        operator ModQList<T>() const {
            qDebug() << "PROXY :: MODQLIST OPERATOR";
            if (var.type() == QMetaType::QString) {
                return ModQList<T>::fromString(*this);
            }
            return var.value<ModQList<T>>();
        }

        QVariant var;
        mutable QVariantList* cachedList;
        mutable QVariantMap* cachedMap;
    };

    Proxy operator[](QString key) const { return Proxy(value(key)); }

    // ---
    // QVariant operator[](const QString& key) const {
    //     QVariant val = value(key);

    //     if (val.canConvert<QVariantMap>()) {
    //         return val.value<QMap<QString, QVariant>>();
    //     }
    //     return val;
    // };
    // ---

    // template <typename T>
    // T value(const QString& key, const QVariant& defaultValue);
};

// class Settings {
//    public:
//     Settings();
//     ModQList<int> CT_Photo;
//     ModQList<int> CT_Text;
//     ModQList<int> CT_TextWPhoto;

//     // ModQMap<QString, ModQList<int>> contentType_Map;
//     QStringList photoCoverage_Options;
//     ModQMap<QString, double> qualityType_Map;
//     ModQMap<QString, double> paperSize_Map;
//     ModQMap<QString, int> paperType_Map;
// };

// Specialization for QString

#endif  // SETTINGS_H

// QVariantMap jsonObjectToVariantMap(const QJsonObject& jsonObject);

// QVariantList jsonArrayToVariantList(const QJsonArray& jsonArray);

// QVariant jsonValueToVariant(const QJsonValue& value);