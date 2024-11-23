// #pragma once
#ifndef MODORDEREDMAP
#define MODORDEREDMAP

#include <QDebug>
#include <QList>
#include <QPair>

#include <QJsonObject>
#include <QVariantMap>

#include <stdexcept>
#include "errorhdlr.cpp"

// QVariantMap serializeJSON(QJsonObject object);

template <typename Value>
class ModOrderedMap {
    // Q_Object

   public:
    void insert(QString key, Value value);
    Value value(QString key);
    QList<QString> keys() const;

    Value operator[](QString key);

    QList<QPair<QString, Value>> list;
    QList<QString> m_key;

    static ModOrderedMap<Value> fromVariant(QVariant var);
    // static ModOrderedMap<Value> fromVariant(const QVariant& var) {
    //     qDebug() << "from variant Called";
    //     ModOrderedMap<Value> result;
    //     if (var.canConvert<QVariantMap>()) {
    //         QVariantMap map = var.toMap();
    //         for (auto it = map.constBegin(); it != map.constEnd(); ++it) {
    //             result.insert(it.key(), it.value().value<Value>());
    //         }
    //     }
    //     return result;

    //     qDebug() << result << "\n";
    // }
    ModOrderedMap<Value> toString(QVariant var);

    QVariant toVariant() const {
        qDebug() << "CALLED\n";
        QVariantMap map;
        for (const auto& pair : list) {
            map.insert(
                pair.first,
                QVariant::fromValue(
                    pair.second));  // Ensure Value is registered with QVariant
        }
        return map;  // Return as QVariantMap
    }
    //    private:
};

// ModOrderedMap<QString> toModOrderedMap(QVariant var);
// #include "ModOrderedMap.cpp"

template <typename Value>
ModOrderedMap<Value> ModOrderedMap<Value>::fromVariant(QVariant var) {
    if (var.canConvert<ModOrderedMap<QString>>()) {
        return var.value<ModOrderedMap<QString>>();
    } else {
        THROW_ERROR("CANNOT CONVERT VALUE TO ModOrderedMap<QString>");
    }
}

template <typename Value>
void ModOrderedMap<Value>::insert(QString key, Value value) {
    if (!m_key.contains(key)) {
        m_key.append(key);
    } else {
        // override behaviour - if exist then remove that and move to the
        int idx = m_key.indexOf(key);
        list.remove(idx);
        m_key.remove(idx);
    }
    list.append(qMakePair(key, value));
};

template <typename Value>
Value ModOrderedMap<Value>::value(QString key) {
    int idx = m_key.indexOf(key);

    if (idx != -1) {
        return list.at(idx).second;
        // qDebug() << "ITEM ACCESSED IS " << item;
        // qDebug() << "ITEM ACCESSED IS " << item;
    } else {
        // THROW_ERROR("INDEX OUT OF RANGE");
    }
}

template <typename Value>
Value ModOrderedMap<Value>::operator[](QString key) {
    return this->value(key);
}

template <typename Value>
QList<QString> ModOrderedMap<Value>::keys() const {
    return m_key;
}

template <typename Value>
QDebug operator<<(QDebug dbg, const ModOrderedMap<Value>& map) {
    dbg.nospace() << "ModOrderedMap(";
    for (const auto& pair : map.list) {
        dbg.nospace() << pair.first << ": " << pair.second << ", ";
    }
    dbg.nospace() << ")";
    return dbg;
}

/* ------------------------------------------------------------------------- */
// template <typename Value>
// class ModList : public QList<Value> {
//    public:
//     ModList<int> fromString(const QString& string);
// };

// template <>
// ModList<int> ModList<int>::fromString(const QString& string) {}

// ModList<int> toIntList(QVariant var);

#endif