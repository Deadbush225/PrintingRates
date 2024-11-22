#include <QApplication>
#include <QColor>
#include <QIcon>
#include <QPalette>
#include <QWidget>
#include <Qt>

#include <QFile>
#include <QJsonArray>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

#include "utils/ModOrderedMap.h"
#include "utils/errorhdlr.cpp"
// #include "DashboardWidget.h"
// #include "Utils/Settings.h"

// void readJsonFile(QIODevice& device,
//                   QList<QPair<QString, QVariant>>& orderedMap) {
//     QByteArray jsonData = device.readAll();
//     QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData);

//     if (jsonDoc.isNull() || !jsonDoc.isObject()) {
//         qWarning() << "Invalid JSON document!";
//         return;
//     }

//     QJsonObject jsonObj = jsonDoc.object();
//     for (const QString& key : jsonObj.keys()) {
//         orderedMap.append(qMakePair(key, jsonObj.value(key).toVariant()));
//     }
// }

Q_DECLARE_METATYPE(ModOrderedMap<QString>)

void setupDarkTheme() {
    // QApplication::setStyle("Fusion");
    // QApplication::setWindowIcon(QIcon(":/Icons/Printing Rates.png"));

    // // # Now use a palette to switch to dark colors:
    // QPalette* dark_palette = new QPalette();
    // dark_palette->setColor(QPalette::Window, QColor(53, 53, 53));
    // dark_palette->setColor(QPalette::WindowText, Qt::white);
    // dark_palette->setColor(QPalette::Base, QColor(35, 35, 35));
    // dark_palette->setColor(QPalette::AlternateBase, QColor(53, 53, 53));
    // dark_palette->setColor(QPalette::ToolTipBase, QColor(25, 25, 25));
    // dark_palette->setColor(QPalette::ToolTipText, Qt::white);
    // dark_palette->setColor(QPalette::Text, Qt::white);
    // dark_palette->setColor(QPalette::Button, QColor(53, 53, 53));
    // dark_palette->setColor(QPalette::ButtonText, Qt::white);
    // dark_palette->setColor(QPalette::BrightText, Qt::red);
    // dark_palette->setColor(QPalette::Link, QColor(42, 130, 218));
    // dark_palette->setColor(QPalette::Highlight, QColor(42, 130, 218));
    // dark_palette->setColor(QPalette::HighlightedText, QColor(35, 35, 35));
    // dark_palette->setColor(QPalette::Active, QPalette::Button, QColor(53, 53,
    // 53)); dark_palette->setColor(QPalette::Disabled, QPalette::ButtonText,
    // Qt::darkGray); dark_palette->setColor(QPalette::Disabled,
    // QPalette::WindowText, Qt::darkGray);
    // dark_palette->setColor(QPalette::Disabled, QPalette::Text, Qt::darkGray);
    // dark_palette->setColor(QPalette::Disabled, QPalette::Light, QColor(53,
    // 53, 53)); QApplication::setPalette(*dark_palette);
}

int main(int argc, char* arg[]) {
    qRegisterMetaType<ModOrderedMap<QString>>("ModOrderedMap<QString>");

    auto app = QApplication(argc, arg);

    setupDarkTheme();

    // auto w = DashboardWidget();
    // w.show();

    // w.setStyleSheet(
    // "*{ border: 1px solid black;} QLabel { padding: 0 0 0 0px; }");

    /* ------------------------------------------------------------ */
    // ModQSettings* e = new ModQSettings();

    // qDebug() << (*e)["Content Type"];
    QString jsonFilePath =
        "C:/system/coding/Projects/printing-rates/src/config.json";
    QFile file(jsonFilePath);

    if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qWarning() << "Could not open the file!";
        return -1;
    }

    // QList<QPair<QString, QVariant>> orderedMap;
    // readJsonFile(file, orderedMap);
    // file.close();
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    qDebug() << doc << "\n";
    // qDebug() << doc.object();
    // qDebug() << doc.object()["Content Type"][1];

    // for (const QPair<QString, QVariant>& pair : orderedMap) {
    //     qDebug() << pair.first << ":" << pair.second.toString();
    // }

    QVariantMap settingsVariant = serializeJSON(doc.object());

    qDebug() << "Returned QVariant: " << settingsVariant << "\n";

    ModOrderedMap<QString> e =
        ModOrderedMap<QString>::fromVariant(settingsVariant["Content Type"]);

    qDebug() << e << "\n";

    qDebug() << e.value("Photo");

    qDebug() << "T" << "\n";

    // QList<QString> i =
    // qDebug() << settingsVariant["Page Coverage"].toStringList();
    // auto var = settingsVariant["Page Coverage"].toStringList();
    // var.append("Test");
    // settingsVariant["Page Coverage"] = var;
    static_cast<QStringList*>(settingsVariant["Page Coverage"].data())
        ->append("TEST");
    qDebug() << "U" << "\n";

    // QStringList& sl = *var.data<QStringList>();
    // sl.append("Test");
    // qDebug() << "Contents of myStringList:";
    // settingsVariant["Page Coverage"].value<QStringList>().append("TEst");
    // QStringList* stringListPtr =

    // settingsVariant["Page
    // Coverage"].value<QStringList*>()->append("TEST");

    // if (stringListPtr) {
    //     qDebug() << "ADDING";
    //     stringListPtr->append("newValue1");
    //     stringListPtr->append("newValue2");
    // }

    qDebug() << settingsVariant["Page Coverage"].toStringList();

    /* ------------------------------------------------------------ */

    qDebug() << "Before Saving: " << settingsVariant << "\n";

    // -> check for other way to initialize QJsonObject using our QVariantMap

    // QJsonObject obj = QJsonObject::fromVariantMap(settingsVariant);

    /* ---------------------------------------------------------------- */
    QJsonObject obj;

    // Iterate through the QVariantMap and insert into QJsonObject
    for (auto it = settingsVariant.constBegin();
         it != settingsVariant.constEnd(); ++it) {
        QString key = it.key();
        QVariant value = it.value();

        // Check if the value is convertible to QJsonValue
        if (value.canConvert<ModOrderedMap<QString>>()) {
            ModOrderedMap<QString> map = value.value<ModOrderedMap<QString>>();
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
                key, QJsonValue::fromVariant(
                         value));  // Directly convert QStringList to QJsonValue
        } else {
            obj.insert(key, QJsonValue::fromVariant(
                                value));  // General case for other types
        }
    }

    /* ---------------------------------------------------------------- */

    qDebug() << "Object: " << obj << "\n";
    // QJsonDocument dc = QJsonDocument::fromVariant(settingsVariant);
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
    qDebug() << "TEST UPDATE";

    auto ret = app.exec();
    return ret;
}
