#include "Settings.h"
#include "ModOrderedMap.h"

#include <vector>

#include <QFile>
#include <QIODevice>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QVariant>
#include <type_traits>

#include <QCoreApplication>
#include <QDataStream>
#include <QDebug>
#include <QMetaType>
#include <QSettings>
#include <QVariant>

#include <QJsonArray>

// Define the operator<< for QDebug and Proxy
QDebug operator<<(QDebug debug, const ModQSettings::Proxy& proxy) {
    QDebugStateSaver saver(debug);
    debug.nospace() << static_cast<QVariant>(proxy);
    return debug;
}

template <typename T>
QDebug operator<<(QDebug debug, const ModQMap<QString, T>& modMap) {
    QDebugStateSaver saver(debug);
    debug.nospace() << static_cast<ModQMap<QString, T>>(modMap);
    return debug;
}

// template <typename T>
// QDebug operator<<(QDebug debug, const ModOrderedMap<T>& orderedMap) {
//     QDebugStateSaver saver(debug);
//     debug.nospace() << "PRINT\n";
//     debug.nospace() << orderedMap.keys() << "\n";
//     debug.nospace() << orderedMap.list << "\n";
//     debug.nospace() << "PRINT END\n";
//     return debug;
// }

bool readJsonFile(QIODevice& device, QSettings::SettingsMap& map) {
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(device.readAll(), &error);
    if (error.error != QJsonParseError::NoError) {
        return false;
    }

    qDebug() << doc;

    map = doc.toVariant().toMap();
    // QVariantMap variantMap = jsonObjectToVariantMap(doc.object());
    qDebug() << map;

    // QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData);
    QJsonObject jsonObj = doc.object();

    // ModOrderedMap<QJsonValue> orderedMap;

    // for (const QString& key : jsonObj.keys()) {
    //     orderedMap.insert(key, jsonObj.value(key));
    // }

    // qDebug() << orderedMap;

    // map = orderedMap;

    // qDebug() << "TESTTTT\n" << variantMap << "\nTESTTTT\n";

    return true;
}

bool writeJsonFile(QIODevice& device, const QSettings::SettingsMap& map) {
    QJsonDocument doc = QJsonDocument::fromVariant(QVariant::fromValue(map));
    device.write(doc.toJson());
    return true;
}

// ModQSettings::ModQSettings() {
//     const QSettings::Format JsonFormat =
//         QSettings::registerFormat("json", readJsonFile, writeJsonFile);

//     this->setPath(JsonFormat, QSettings::UserScope,
//                   QCoreApplication::applicationDirPath() + "/config.json");
// }

// // Function to convert QJsonObject to QVariantMap
// QVariantMap jsonObjectToVariantMap(const QJsonObject& jsonObject) {
//     QVariantMap variantMap;
//     for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it) {
//         variantMap.insert(it.key(), jsonValueToVariant(it.value()));
//     }
//     return variantMap;
// }

// // Function to convert QJsonArray to QVariantList
// QVariantList jsonArrayToVariantList(const QJsonArray& jsonArray) {
//     QVariantList variantList;
//     for (int i = 0; i < jsonArray.size(); ++i) {
//         variantList.append(jsonValueToVariant(jsonArray[i]));
//     }
//     return variantList;
// }

// // Function to convert QJsonValue to QVariant
// QVariant jsonValueToVariant(const QJsonValue& value) {
//     if (value.isObject()) {
//         return jsonObjectToVariantMap(value.toObject());
//     } else if (value.isArray()) {
//         return jsonArrayToVariantList(value.toArray());
//     } else {
//         return value.toVariant();
//     }
// }

// QDataStream& operator<<(QDataStream& out, const ModQList<int>& list) {
//     out << static_cast<const QList<int>&>(list);
//     return out;
// }

// QDataStream& operator>>(QDataStream& in, ModQList<int>& list) {
//     in >> static_cast<QList<int>&>(list);
//     return in;
// }

// Settings::Settings() {
//         // this->setPath(JsonFormat, QSettings::UserScope,
//     //   QCoreApplication::applicationDirPath() + "/config.json");

//     qRegisterMetaType<ModQList<int>>("ModQList<int>");
//     // qRegisterMetaTypeStreamOperators<ModQList<int>>("ModQList<int>");

//     // qDebug() << "TEST\n" << settings->value("Content Typetst");
//     // qDebug() << "TEST\n" << (*settings)["Content Typetst"]["Photo"];
//     // qDebug() << "TEST\n" << (*settings)["Content
//     Typetst"].toMap()["Photos"]; settings = new ModQSettings();

//     // auto CT_Photo_default = ModQList<int>({1, 2, 3, 4, 5, 5});
//     // auto CT_Text_default = ModQList<int>({5, 5, 4, 4, 3, 3});
//     // auto CT_TextWPhoto_default = ModQList<int>({8, 7, 6, 5, 4, 4});

//     // this->contentType_Map["Photo"] = (*settings)["Content Type"]["Photo"];
//     // ModQSettings::Proxy
//     QMap<QString, QList<int>> r = (*settings)["Content Type"];
//     //
//     qDebug() << "TESTTT\n" << r;
//     qDebug() << "TESTTT\n" << (*settings).allKeys();
//     qDebug() << "INDEX ACCESS\n" << (*settings)["Content Type"]["Photo"][0];
//     int e = (*settings)["Content Type"]["Photo"][0].toVariant().toInt();

//     // std::cout << decltype(e);

//     qDebug() << "LIST PRINT\n" << (*settings)["Content Type"]["Photo"];
//     qDebug() << "MAP PRINT\n" << (*settings)["Content Type"];
//     // qDebug() << "TESTTT\n"
//     //          << (*settings)["Content Type"].toVariant().toMap().keys();
//     // qDebug()
//     //     << "TESTTT\n"
//     //     << static_cast<QVariant>((*settings)["Content
//     Type"]).toMap().keys();
//     // qDebug() << "TESTTT\n"
//     //          << static_cast<QVariant>((*settings)["Content Type"])
//     //                 .value<QMap<QString, QVariantMap>>();
//     // qDebug() << "TESTTT\n"
//     //          << static_cast<QVariant>((*settings)["Content Type"])
//     //                 .value<QMap<QString, QVariantMap>>()
//     //                 .keys();
//     // qDebug() << "TESTTT\n"
//     //          << static_cast<QMap<QString, QVariant>>(
//     //                 (*settings)["Content Type"]);
//     // qDebug() << "TESTTT\n" << (*settings)["Content Type"]["Photo"];
//     // qDebug() << "TESTTT\n" << (*settings)["Content Type"];
//     // this->contentType_Map["Photo"] =
//     // settings->value<ModQList<int>>("ContentType/Photo",
//     // CT_Photo_default);
//     // this->contentType_Map["Text"] =
//     //     settings->value<ModQList<int>>("ContentType/Text",
//     CT_Photo_default);
//     // this->contentType_Map["Text \\w Photo"] =
//     settings->value<ModQList<int>>(
//     //     "ContentType/TextwPhoto", CT_Photo_default);

//     // auto PC_Options_default =
//     //     QStringList({"Full", "5/6", "4/6", "Half", "2/6", "1/6"});

//     // this->photoCoverage_Options = settings->value<QStringList>(
//     //     "PhotoCoverage/Options", PC_Options_default);

//     // this->qualityType_Map["Draft"] =
//     //     settings->value("ContentType/Draft", 0.4).toInt();
//     // this->qualityType_Map["Standard"] =
//     //     settings->value("ContentType/Standard", 1).toInt();
//     // this->qualityType_Map["Standard-Vivid"] =
//     //     settings->value("ContentType/Standard-Vivid", 1.3).toInt();
//     // this->qualityType_Map["High"] =
//     //     settings->value("ContentType/High", 1.7).toInt();

//     // this->paperSize_Map["Short"] =
//     //     settings->value("PaperSize/Short", 1).toInt();
//     // this->paperSize_Map["A4"] =
//     settings->value("PaperSize/A4", 1.1).toInt();
//     // this->paperSize_Map["Long"] =
//     //     settings->value("PaperSize/Long", 1.2).toInt();

//     // this->paperType_Map["Plain"] =
//     //     settings->value("PaperType/Plain", 0).toInt();
//     // this->paperType_Map["Colored Paper"] =
//     //     settings->value("PaperType/Colored-Paper", 1).toInt();
//     // this->paperType_Map["Sticker Paper"] =
//     //     settings->value("PaperType/Sticker-Paper", 10).toInt();
//     // this->paperType_Map["Matte"] =
//     // settings->value("PaperType/Matte").toInt(); this->paperType_Map["Ultra
//     // Glossy"] =
//     //     settings->value("PaperType/Ultra-Glossy", 25).toInt();
//     // this->paperType_Map["Premium Glossy"] =
//     //     settings->value("PaperType/Premium-Glossy", 25).toInt();
//     // this->paperType_Map["Premium Semigloss"] =
//     //     settings->value("PaperType/Premium-Semigloss", 25).toInt();
//     // this->paperType_Map["Photo Paper Glossy"] =
//     //     settings->value("PaperType/Photo-Paper-Glossy", 20).toInt();

//     // settings->setValue("ContentType/Photo", contentType_Map["Photo"]);
//     // settings->setValue("ContentType/Text", contentType_Map["Text"]);
//     // settings->setValue("ContentType/TextwPhoto",
//     // contentType_Map["TextwPhoto"]);

//     // settings->setValue("PhotoCoverage/Options", photoCoverage_Options);

//     // settings->setValue("QualityType/Draft", qualityType_Map["Draft"]);
//     // settings->setValue("QualityType/Standard",
//     qualityType_Map["Standard"]);
//     // settings->setValue("QualityType/Standard-Vivid",
//     //                    qualityType_Map["Standrd-Vivid"]);
//     // settings->setValue("QualityType/High", qualityType_Map["High"]);

//     // settings->setValue("PaperType/Plain", qualityType_Map["Plain"]);
//     // settings->setValue("PaperType/Colored-Paper",
//     qualityType_Map["Plain"]);
//     // settings->setValue("PaperType/Sticker-Paper",
//     qualityType_Map["Plain"]);
//     // settings->setValue("PaperType/Matte", qualityType_Map["Plain"]);
//     // settings->setValue("PaperType/Matte", qualityType_Map["Plain"]);
//     // settings->setValue("PaperType/Matte", qualityType_Map["Plain"]);
//     // settings->setValue("PaperType/Matte", qualityType_Map["Plain"]);
// }

QList<QVariant> convertToQVariantList(const QList<int>& intList) {
    QList<QVariant> variantList;
    for (int value : intList) {
        variantList.append(QVariant(value));
    }
    return variantList;
}

template <typename T>
QString ModQList<T>::toString() {
    QString string;

    for (auto i = this->begin(), j = this->end(); i != j; i++) {
        string += QVariant(*i).toString();

        if (i + 1 != j) {
            string += ", ";
        }
    }
    return string;
}

template <typename T>
ModQList<int> ModQList<T>::fromString(const QString& string) {
    qDebug() << "FROM STRING WITH INT";

    ModQList<int> stringList = ModQList<QString>::fromString(string);

    ModQList<int> outputList;
    for (auto i = stringList.begin(), j = stringList.end(); i != j; i++) {
        qDebug() << *i;
        outputList.append(QVariant(*i).toInt());
    }

    return outputList;
}

template <>
ModQList<int> ModQList<QString>::fromString(const QString& string) {
    qDebug() << "FROM STRING WITH STRING";
    qDebug() << string;

    QStringList stringList = string.split(", ", Qt::SkipEmptyParts);

    qDebug() << stringList;

    ModQList<int> result;
    for (const QString& str : stringList) {
        qDebug() << str;
        result.append(str.toInt());
    }

    return result;
}

// Compile time checker
template <typename T, typename = void>
struct is_iterable : std::false_type {};

template <typename T>
struct is_iterable<
    T,
    std::void_t<  // Final check if we can map each value to void
        decltype(std::begin(std::declval<T&>()) !=
                 std::end(std::declval<T&>())),  // Check if begin and end exist
        decltype(++std::declval<decltype(std::begin(
                     std::declval<T&>()))&>()),  // Check if we can increment
                                                 // the iterator
        decltype(*std::begin(std::declval<T&>()))>> : std::true_type {
};  // Check if we can dereference the iterator

// template <typename T>
// T ModQSettings::value(const QString& key, const QVariant& defaultValue) {
//     auto value = QSettings::value(key);

//     if (!value.isValid()) {
//         qDebug() << "INVALID";
//         // return ModQList<int>::fromString(defaultValue.toString());
//         qDebug() << defaultValue.value<T>();
//         return defaultValue.value<T>();
//     }

//     qDebug() << "VALID";
//     if constexpr (std::is_same<T, QStringList>::value) {
//         return value.toStringList();
//     } /*else if (std::is_same<T, int>::value) {
//         return value.toInt();
//     } */
//     else if constexpr (is_iterable<T>::value) {
//         return ModQList<int>::fromString(value.toString());
//     }
// }
