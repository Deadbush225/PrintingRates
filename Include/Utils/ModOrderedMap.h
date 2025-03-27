#ifndef MODORDEREDMAP
#define MODORDEREDMAP

#include <QDebug>
#include <QList>
#include <QPair>

#include <QJsonObject>
#include <QVariantMap>

#include <stdexcept>
#include "Utils/errorhdlr.h"

// QVariantMap serializeJSON(QJsonObject object);

template <typename Value>
class ModOrderedMap {
    // Q_Object

   public:
    void insert(QString key, Value value);

    // Value& value(const QString& key);
    Value& value(const QString& key) {
        // qDebug() << key << "+++++++++++++++";
        int idx = m_key.indexOf(key);

        Value val = list[idx].second;

        if (idx == -1) {
            THROW_ERROR("INDEX OUT OF RANGE");
            // qDebug() << "INDEX OUT OF RANGE";
        }

        return list[idx].second;
    }

    QList<QString> keys() const;

    // Value& operator[](QString key);
    Value& operator[](const QString& key) { return this->value(key); }

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

// // make that in serializeJson, we actually do the conversion there
// QStringList ModOrderedMap<QString>::value(const QString& key) {
//     int idx = m_key.indexOf(key);
//     if (idx == -1) {
//         THROW_ERROR("INDEX OUT OF RANGE");
//     }

//     QString val = list[idx].second;
//     if (val.contains(',')) {
//         list[idx].second = val;  // Update the stored value
//         return val.split(',');
//     } else {
//         return QStringList() << val;
//     }
// }

template <typename Value>
ModOrderedMap<Value> ModOrderedMap<Value>::fromVariant(QVariant var) {
    if (var.canConvert<ModOrderedMap<QVariant>>()) {
        return var.value<ModOrderedMap<QVariant>>();
    } else {
        THROW_ERROR("CANNOT CONVERT VALUE TO ModOrderedMap<QString>");
        // qDebug() << "CANNOT CONVERT VALUE TO ModOrderedMap<QString>";
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

#endif