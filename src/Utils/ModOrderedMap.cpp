

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