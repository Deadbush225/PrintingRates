#include "../Include/Utils/JsonSettings.h"

#include <QDebug>
#include <QVariantMap>

#include <QRegularExpression>

#include <QJsonArray>
#include <QJsonObject>

#include <sstream>
#include <stdexcept>

#include "../Include/Utils/EVariantMap.h"
#include "../Include/Utils/ModOrderedMap.h"
#include "errorhdlr.cpp"

// ModOrderedMap<QString> JsonArray_to_Map(QJsonArray arr) {
//     qDebug() << "+++ JsonArray_to_Map +++" << "\n";
//     ModOrderedMap<QString> e;

//     for (auto a : arr) {
//         if (a.isObject()) {
//             // qDebug() << "T";
//             QJsonObject oj = a.toObject();
//             QString key = oj.keys()[0];
//             QString value = oj[key].toString();

//             if (value.contains(",")) {
//                 e.insert(key, value.split(", "));
//             }

//             e.insert(key, value);
//             qDebug() << key << ":" << value;
//         }
//     }
//     qDebug() << e.m_key;
//     qDebug() << e.list;
//     qDebug() << "--- JsonArray_to_Map ---" << "\n";
//     return e;
// }

ModOrderedMap<QVariant> JsonArray_to_Map(QJsonArray arr) {
    // qDebug() << "+++ JsonArray_to_Map +++" << "\n";
    ModOrderedMap<QVariant> e;

    // QString str = "1234";               // Example input
    QRegularExpression re("^[0-9]+$");  // Regex for digits only

    for (auto a : arr) {
        if (a.isObject()) {
            // qDebug() << "T";
            QJsonObject oj = a.toObject();
            QString key = oj.keys()[0];
            QString value = oj[key].toString();

            if (value.contains(",")) {
                // qDebug() << "Converting to stringList: -------";
                QList<QString> stringList = value.split(", ");
                QList<int> intList;
                for (QString s : stringList) {
                    intList.append(s.toInt());
                }

                e.insert(key, QVariant::fromValue(intList));
                continue;
            } else if (value.contains(".")) {
                // qDebug() << "Converting to double: -------";
                bool ok;  // Variable to check if conversion was successful
                double doubleValue = value.toDouble(&ok);  // Attempt conversion
                if (ok) {
                    e.insert(
                        key,
                        doubleValue);  // Insert only if conversion succeeded
                } else {
                    qDebug()
                        << "Conversion to double failed for value:" << value;
                }
                continue;
            } else if (re.match(value).hasMatch()) {
                // qDebug() << "Converting to double: -------";
                int intString = value.toInt();
                e.insert(key, QVariant::fromValue(intString));
                continue;
            }

            e.insert(key, value);
            // qDebug() << key << ":" << value;
        }
    }
    // qDebug() << e.m_key;
    // qDebug() << e.list;
    // qDebug() << "--- JsonArray_to_Map ---" << "\n";
    return e;
}

/*
if the content is a list:
    - if it's a object, it means the sequence must be presereved
    - if it's a string, it must be just a list of string
*/

EVariantMap serializeJSON(QJsonObject object) {
    // qDebug() << "+++ Serialize JSON +++";
    qDebug() << object.keys() << "\n";

    EVariantMap m_map;

    QString key;
    QJsonValue value;

    for (auto e = object.constBegin(); e != object.constEnd(); ++e) {
        key = e.key();
        value = e.value();

        // qDebug() << "Key: " << key << "\n";
        // qDebug() << "Value: " << value << "\n";
        if (value.isArray()) {
            // qDebug() << "Value is Array" << "\n";
            QJsonValue probe = value.toArray()[0];

            if (probe.isObject()) {
                ModOrderedMap<QVariant> map = JsonArray_to_Map(value.toArray());
                // qDebug() << map["Photo"];
                // qDebug() << map["Text"];
                // qDebug() << "Element is MAP: \n";  // << map;

                // qDebug() << map.m_key << "\n";
                // qDebug() << map.list << "\n";

                // qDebug() << "To Array: " << value.toArray();
                // qDebug() << map;
                // qDebug() << "Variant: " << QVariant::fromValue(map);

                m_map.insert(key, QVariant::fromValue(map));
                // m_map.insert(key, map.toVariant());
            } else if (probe.isString()) {
                QList<QString> array = value.toVariant().toStringList();
                // qDebug() << array;
                // qDebug() << array[0];

                // qDebug() << "Element is ARRAY: \n" << array;

                m_map.insert(key, array);
            }
        }
    }

    // qDebug() << m_map;
    // qDebug() << "Content Type";
    // qDebug() << m_map["Content Type"].value<ModOrderedMap<QString>>().value(
    //     "Photo");

    // qDebug() << "--- Serialize JSON ---" << "\n";

    return m_map;
}