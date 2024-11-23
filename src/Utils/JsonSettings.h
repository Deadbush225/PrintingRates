#ifndef JSON_SETTINGS
#define JSON_SETTINGS

#include <QJsonArray>
#include <QJsonObject>
#include <QString>
#include <QVariantMap>

#include <QFile>
#include <QIODevice>
#include <QJsonDocument>

#include "EVariantMap.h"
#include "ModOrderedMap.h"

ModOrderedMap<QString> JsonArray_to_Map(QJsonArray arr);
EVariantMap serializeJSON(QJsonObject object);

class JsonSettings {
   private:
    EVariantMap settingsVariant;

   public:
    EVariantMap* LoadJson() {
        QString jsonFilePath =
            "C:/system/coding/Projects/printing-rates/src/config.json";
        QFile file(jsonFilePath);

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

    void saveJson() {
        qDebug() << "Before Saving: " << this->settingsVariant << "\n";

        QJsonObject obj;

        // Iterate through the QVariantMap and insert into QJsonObject instead
        // of using QJsonObject obj =
        // QJsonObject::fromVariantMap(settingsVariant);
        for (auto it = this->settingsVariant.constBegin();
             it != this->settingsVariant.constEnd(); ++it) {
            QString key = it.key();
            QVariant value = it.value();

            // Check if the value is convertible to QJsonValue
            if (value.canConvert<ModOrderedMap<QString>>()) {
                ModOrderedMap<QString> map =
                    value.value<ModOrderedMap<QString>>();
                QJsonArray arr;

                // Convert ModOrderedMap to QJsonObject
                for (const auto& pair : map.list) {
                    QJsonObject obj;
                    obj.insert(pair.first, pair.second);
                    arr.append(obj);  // Assuming Value is QString or
                                      // convertible to QJsonValue
                }
                obj.insert(key, arr);
            } else if (value.canConvert<QStringList>()) {
                obj.insert(
                    key,
                    QJsonValue::fromVariant(
                        value));  // Directly convert QStringList to QJsonValue
            } else {
                obj.insert(key, QJsonValue::fromVariant(
                                    value));  // General case for other types
            }
        }

        qDebug() << "Object: " << obj << "\n";
        QJsonDocument dc = QJsonDocument(obj);
        qDebug() << "DC: " << dc;
        // qDebug() << settingsVariant["Content Type"];
        // qDebug() << toModOrderedMap(settingsVariant["Content
        // Type"]).value("Photo");
        QString jsonFilePathOut =
            "C:/system/coding/Projects/printing-rates/src/config_out.json";

        QFile fileout(jsonFilePathOut);
        fileout.open(QIODevice::ReadWrite | QIODevice::Text);
        fileout.write(dc.toJson());
        fileout.close();
    }
};

#endif  // JSON_SETTINGS