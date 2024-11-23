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

#include "Utils/JsonSettings.h"
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

    // -> Create an easy way to access these values
    JsonSettings* settings = new JsonSettings();

    EVariantMap* settingsVariant = settings->LoadJson();

    ModOrderedMap<QString>* e = (*settingsVariant).getDict("Content Type");
    // ModOrderedMap<QString>::fromVariant((*settingsVariant)["Content Type"]);

    // if (e == nullptr) {
    //     qDebug() << "NULLPTR";
    //     exit(1);
    // }

    qDebug() << "E: " << (*e) << "\n";
    // qDebug() << "E[\"Photo\"]: " << (*e)["Photo"] << "\n";
    // qDebug() << "Value of \"Photo\"" << (*e).value("Photo");
    // (*e).insert("Photo3", "test");
    // qDebug() << "Value of \"Photo3\"" << (*e).value("Photo3");

    // QStringList var = settingsVariant["Page Coverage"].toStringList();
    // var.append("Test");
    // settingsVariant["Page Coverage"] = var;
    auto r = (*settingsVariant).getStringList("Page Coverage");

    qDebug() << *r;
    if (r == nullptr) {
        qDebug() << "NULLPTR";
        exit(1);
    }

    qDebug() << static_cast<QStringList*>(
        (*settingsVariant)["Page Coverage"].data());

    auto star =
        static_cast<QStringList*>((*settingsVariant)["Page Coverage"].data());
    star->append("TEST");
    //     ->append("TEST");

    // auto st = (*settingsVariant).getStringList("Page Coverage");
    qDebug() << *star;
    // qDebug() << (*st);
    // (*settingsVariant).getStringList("Page Coverage")->append("Test");
    qDebug() << "U" << "\n";

    // QStringList* stringListPtr = settingsVariant["Page
    // Coverage"].value<QStringList*>();

    // if (stringListPtr) {
    //     qDebug() << "ADDING";
    //     stringListPtr->append("newValue1");
    //     stringListPtr->append("newValue2");
    // }

    qDebug() << (*settingsVariant)["Page Coverage"].toStringList();
    settings->saveJson();
    qDebug() << "TEST UPDATE";

    auto ret = app.exec();
    return ret;
}
