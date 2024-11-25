#ifndef E_VARIANT_MAP
#define E_VARIANT_MAP

#include <QString>
#include <QVariant>
#include <QVariantMap>

#include "ModOrderedMap.h"

#include <memory>

class EVariantMap : public QVariantMap {
   public:
    using QVariantMap::QVariantMap;  // Inherit constructors

    template <typename ValueType>
    ValueType* getValue(const QString& key) {
        if (!contains(key)) {
            qDebug() << "KEY NOT FOUND";
            return nullptr;
        }
        QVariant variant = this->value(key);

        if (!variant.canConvert<ValueType>()) {
            qDebug() << "UNABLE TO CONVERT TO ModOrderedMap<QString>";
            return nullptr;
        }

        // can't use (*this).value(key).data() for some reason
        return static_cast<ValueType*>((*this)[key].data());
    }

    // you can use this shorthand to shorten calls for getDict and getStringList
    // ModOrderedMap<QVariant>* operator[](QString key) {
    //     return getValue<ModOrderedMap<QVariant>>(key);
    // }
    // QStringList* operator()(QString key) {
    //     // return getStringList(key);
    //     return getValue<QStringList>(key);
    // }

    ModOrderedMap<QVariant>* getDict(const QString& key) {
        return getValue<ModOrderedMap<QVariant>>(key);
    }

    QStringList* getStringList(const QString& key) {
        qDebug() << key << "\n";
        return getValue<QStringList>(key);
    }

    // Overload for QString
    // QString getString(const QString& key, const QString& defaultValue =
    // QString()) const {
    //     return getValue<QString>(key, defaultValue);
    // }

    // Overload for int
    // int getInt(const QString& key, int defaultValue = 0) const {
    //     return getValue<int>(key, defaultValue);
    // }

    // Add more overloads as needed for different types...
};

#endif  // E_VARIANT_MAP