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

    // Method to get a value of type T
    // template <typename T>
    // T getValue(const QString& key, const T& defaultValue = T()) const {
    //     if (contains(key)) {
    //         return value(key).value<T>();  // Safely convert to T
    //     }
    //     return defaultValue;  // Return default if key doesn't exist
    // }

    template <typename ValueType>
    ValueType* getValue(const QString& key) {
        if (!contains(key)) {
            qDebug() << "KEY NOT FOUND";
            return nullptr;
        }
        QVariant variant = this->value(key);
        if (!variant.canConvert<ValueType>()) {
            qDebug() << "UNABLE TO CONVERT TO" << typeid(ValueType).name();
            return nullptr;
        }
        return static_cast<ValueType*>((*this)[key].data());
    }  // Specialization for QStringList
    QStringList* getStringList(const QString& key) {
        return getValue<QStringList>(key);
    }  // Specialization
    // for ModOrderedMap<QString>
    ModOrderedMap<QString>* getDict(const QString& key) {
        return getValue<ModOrderedMap<QString>>(key);
    }

    // template <typename Value>
    // Value* getValue(const QString& key) const {
    //     if (!contains(key)) {
    //         qDebug() << "KEY NOT FOUND";
    //         return nullptr;
    //     }
    //     QVariant variant = this->value(key);

    //     // if (!variant.canConvert<Value>()) {
    //     //     // std::to_string(Value);
    //     //     qDebug() << "UNABLE TO CONVERT TO ModOrderedMap<QString>";
    //     //     return nullptr;
    //     // }

    //     // return static_cast<Value*>(variant.data());
    //     return static_cast<Value*>((*this)[key].data());
    //     // return value.value<Value>();  // Safely convert
    //     // return static_cast<QStringList*>(
    //     //     value.value<Value>());  // Safely convert
    //     // return static_cast<Value*>(
    //     // this->operator[](key).data());  // Safely convert
    // }

    // ModOrderedMap<QString>* getDict(const QString& key,
    //                                 const ModOrderedMap<QString>
    //                                 defaultValue
    //                                 =
    //                                     ModOrderedMap<QString>()) const {
    //     return getValue<ModOrderedMap<QString>>(key, defaultValue);
    // }

    // QStringList* getStringList(const QString& key,
    //                            const QStringList defaultValue =
    //                            QStringList()) {
    //     return getValue<QStringList>(key);
    // }

    // QStringList* getStringList(const QString& key) {
    //     if (!contains(key)) {
    //         qDebug() << "KEY NOT FOUND";
    //         return nullptr;
    //     }
    //     QVariant variant = this->value(key);

    //     if (!variant.canConvert<QStringList>()) {
    //         qDebug() << "UNABLE TO CONVERT TO QStringList";
    //         return nullptr;
    //     }

    //     return static_cast<QStringList*>((*this)[key].data());
    // }

    // ModOrderedMap<QString>* getDict(const QString& key) {
    //     if (!contains(key)) {
    //         qDebug() << "KEY NOT FOUND";
    //         return nullptr;
    //     }
    //     QVariant variant = this->value(key);

    //     if (!variant.canConvert<ModOrderedMap<QString>>()) {
    //         qDebug() << "UNABLE TO CONVERT TO ModOrderedMap<QString>";
    //         return nullptr;
    //     }

    //     return static_cast<ModOrderedMap<QString>*>((*this)[key].data());
    // }

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