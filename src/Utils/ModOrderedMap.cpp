#include <QDebug>
#include <QVariantMap>

#include <QJsonArray>
#include <QJsonObject>

#include <sstream>
#include <stdexcept>

#include "ModOrderedMap.h"
#include "errorhdlr.cpp"

ModOrderedMap<QString> JsonArray_to_Map(QJsonArray arr) {
    qDebug() << "+++ JsonArray_to_Map +++" << "\n";
    ModOrderedMap<QString> e;

    for (auto a : arr) {
        if (a.isObject()) {
            // qDebug() << "T";
            QJsonObject oj = a.toObject();
            QString key = oj.keys()[0];
            QString value = oj[key].toString();
            e.insert(key, value);
            qDebug() << key << ":" << value;
        }
    }
    qDebug() << e.m_key;
    qDebug() << e.list;
    qDebug() << "--- JsonArray_to_Map ---" << "\n";
    return e;
}

QVariantMap serializeJSON(QJsonObject object) {
    qDebug() << "+++ Serialize JSON +++";
    qDebug() << object.keys() << "\n";

    QVariantMap m_map;

    QString key;
    QJsonValue value;

    for (auto e = object.constBegin(); e != object.constEnd(); ++e) {
        key = e.key();
        value = e.value();

        qDebug() << "Key: " << key << "\n";
        qDebug() << "Value: " << value << "\n";
        if (value.isArray()) {
            qDebug() << "Value is Array" << "\n";
            QJsonValue probe = value.toArray()[0];

            if (probe.isObject()) {
                ModOrderedMap<QString> map = JsonArray_to_Map(value.toArray());
                // qDebug() << map["Photo"];
                // qDebug() << map["Text"];
                qDebug() << "Element is MAP: \n";  // << map;

                qDebug() << map.m_key << "\n";
                qDebug() << map.list << "\n";

                qDebug() << "To Array: " << value.toArray();
                // qDebug() << map;
                qDebug() << "Variant: " << QVariant::fromValue(map);

                m_map.insert(key, QVariant::fromValue(map));
                // m_map.insert(key, map.toVariant());
            } else if (probe.isString()) {
                QList<QString> array = value.toVariant().toStringList();
                // qDebug() << array;
                // qDebug() << array[0];

                qDebug() << "Element is ARRAY: \n" << array;

                m_map.insert(key, array);
            }
        }
    }

    // qDebug() << m_map;
    // qDebug() << "Content Type";
    // qDebug() << m_map["Content Type"].value<ModOrderedMap<QString>>().value(
    //     "Photo");

    qDebug() << "--- Serialize JSON ---" << "\n";

    return m_map;
}

// QJsonObject deserializeJSON(QVariantMap map) {
//     QJsonObject m_obj;

//     QString key;
//     QVariant value;

//     for (auto e = map.constBegin(); e != map.constEnd(); ++e) {
//         key = e.key();
//         value = e.value();

//         qDebug() << value << "\n";
//         qDebug() << key << "\n";
//         if (value.isArray()) {
//             // qDebug() << "TST";
//             // probe if the first item is an object

//             QJsonValue probe = value.toArray()[0];

//             if (probe.isObject()) {
//                 ModOrderedMap<QString> map =
//                 JsonArray_to_Map(value.toArray());
//                 // qDebug() << map["Photo"];
//                 // qDebug() << map["Text"];
//                 qDebug() << "MAP: ";  // << map;

//                 m_map.insert(key, QVariant::fromValue(map));
//             } else if (probe.isString()) {
//                 QList<QString> array = value.toVariant().toStringList();
//                 // qDebug() << array;
//                 // qDebug() << array[0];

//                 qDebug() << "ARRAY :" << array;

//                 m_map.insert(key, array);
//             }
//         }
//     }

//     // qDebug() << m_map;
//     // qDebug() << "Content Type";
//     // qDebug() << m_map["Content
//     Type"].value<ModOrderedMap<QString>>().value(
//     //     "Photo");
//     return m_map;
// }