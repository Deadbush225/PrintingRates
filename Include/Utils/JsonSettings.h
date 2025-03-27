#ifndef JSON_SETTINGS
#define JSON_SETTINGS

#include <QCoreApplication>

#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QVariantMap>

#include <QFile>
#include <QIODevice>
#include <QJsonDocument>

#include "EVariantMap.h"
#include "ModOrderedMap.h"

ModOrderedMap<QVariant> JsonArray_to_Map(QJsonArray arr);
EVariantMap serializeJSON(QJsonObject object);

class JsonSettings {
   private:
    EVariantMap settingsVariant;
    std::string defaultContents = R"({
	"Content Type": [
		{ "Text3": "3, 3, 4, 4, 5, 5" },
		{ "Text": "3, 3, 4, 4, 5, 5" },
		{ "Text2": "3, 3, 4, 4, 5, 5" },
		{ "TextwPhoto": "4, 5, 5, 6, 7, 8" }
	],
	"Page Coverage": ["1/6", "2/6", "Half", "4/6", "5/6", "Full"],
	"Quality Type": [
		{ "Draft": "0.4" },
		{ "Standard": "1" },
		{ "Standard Vivid": "1.3" },
		{ "High": "1.7" }
	],
	"Paper Size": [{ "Short": "1" }, { "A4": "1.1" }, { "Long": "1.2" }],
	"Paper Type": [
		{ "Plain": "1" },
		{ "Colored Paper": "3" },
		{ "Sticker Paper": "15" },
		{ "Matte": "15" },
		{ "Ultra Glossy": "23" },
		{ "Premium Semigloss": "23" },
		{ "Photo Paper Glossy": "23" },
		{ "Photo Paper Glossy 23": "23" }
	]
})";

   public:
    EVariantMap* LoadJson() {
        QString relativeJsonFilePath =
            QCoreApplication::applicationDirPath() + "/config.json";
        QFile file(relativeJsonFilePath);

        qDebug() << relativeJsonFilePath;

        if (!file.exists()) {
            qDebug() << "Creating configuration file";
            if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
                qWarning() << "Could not create the file!";
                exit(-1);
            }
            qDebug() << "Writing into configuration file";
            QTextStream out(&file);
            out << QString::fromStdString(this->defaultContents);
            file.close();
        }

        if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
            qWarning() << "Could not open the file!";
            exit(-1);
        }

        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        file.close();

        qDebug() << doc << "\n";

        this->settingsVariant = serializeJSON(doc.object());

        qDebug() << "Returned QVariant: " << this->settingsVariant << "\n";
        return &(this->settingsVariant);
    }

    // currently we don't change the json so we don't need to write changes,
    // leaving this unmodified but refer to the serializeJson to update this
    // void saveJson() {
    //     qDebug() << "Before Saving: " << this->settingsVariant << "\n";

    //     QJsonObject obj;

    //     // Iterate through the QVariantMap and insert into QJsonObject
    //     instead
    //     // of using QJsonObject obj =
    //     // QJsonObject::fromVariantMap(settingsVariant);
    //     for (auto it = this->settingsVariant.constBegin();
    //          it != this->settingsVariant.constEnd(); ++it) {
    //         QString key = it.key();
    //         QVariant value = it.value();

    //         // Check if the value is convertible to QJsonValue
    //         if (value.canConvert<ModOrderedMap<QString>>()) {
    //             ModOrderedMap<QString> map =
    //                 value.value<ModOrderedMap<QString>>();
    //             QJsonArray arr;

    //             // Convert ModOrderedMap to QJsonObject
    //             for (const auto& pair : map.list) {
    //                 QJsonObject obj;
    //                 obj.insert(pair.first, pair.second);
    //                 arr.append(obj);  // Assuming Value is QString or
    //                                   // convertible to QJsonValue
    //             }
    //             obj.insert(key, arr);
    //         } else if (value.canConvert<QStringList>()) {
    //             obj.insert(
    //                 key,
    //                 QJsonValue::fromVariant(
    //                     value));  // Directly convert QStringList to
    //                     QJsonValue
    //         } else {
    //             obj.insert(key, QJsonValue::fromVariant(
    //                                 value));  // General case for other types
    //         }
    //     }

    //     qDebug() << "Object: " << obj << "\n";
    //     QJsonDocument dc = QJsonDocument(obj);
    //     qDebug() << "DC: " << dc;
    //     // qDebug() << settingsVariant["Content Type"];
    //     // qDebug() << toModOrderedMap(settingsVariant["Content
    //     // Type"]).value("Photo");
    //     QString jsonFilePathOut =
    //         "C:/system/coding/Projects/printing-rates/src/config_out.json";

    //     QFile fileout(jsonFilePathOut);
    //     fileout.open(QIODevice::ReadWrite | QIODevice::Text);
    //     fileout.write(dc.toJson());
    //     fileout.close();
    // }
};

#endif  // JSON_SETTINGS