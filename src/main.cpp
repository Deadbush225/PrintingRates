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

#include "DashboardWidget.h"
#include "Utils/JsonSettings.h"
#include "utils/ModOrderedMap.h"

// #include "Utils/Settings.h"
// #include "utils/errorhdlr.cpp"

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

    // setupDarkTheme();

    auto w = DashboardWidget();
    w.show();

    // w.setStyleSheet(
    // "*{ border: 1px solid black;} QLabel { padding: 0 0 0 0px; }");

    /* ------------------------------------------------------------ */
    // ModQSettings* e = new ModQSettings();

    /* -------------------------------------------------------------------------
     */
    // JsonSettings* settings = new JsonSettings();

    // qDebug() << "S:";

    // EVariantMap* settingsVariant = settings->LoadJson();

    // qDebug() << "R:";

    // ModOrderedMap<QVariant>* e = (*settingsVariant).getDict("Content Type");
    // ModOrderedMap<QVariant>* e = (*settingsVariant).getDict("Paper Type");
    // ModOrderedMap<QVariant>* f = (*settingsVariant).getDict("Quality Type");
    /* -------------------------------------------------------------------------
     */
    // ModOrderedMap<QVariant>* e = (*settingsVariant).getDict("Content Type");
    // ModOrderedMap<QVariant>* e = (*settingsVariant)["Content Type"];

    // qDebug() << "V: ";
    // qDebug() << "E: " << (*e)["Text"].toStringList() << "\n";

    // qDebug() << "E[\"Photo\"]: " << (*e) << "\n";
    // qDebug() << "E[\"Photo\"]: " << (*f)["Draft"] << "\n";
    // qDebug() << "E[\"Photo\"]: " << (*e)["Short"].value<double>() << "\n";
    // qDebug() << "E[\"Photo\"]: " << (*e)["Photo"] << "\n";
    // qDebug() << "Value of \"Photo\"" << (*e).value("Photo");
    // (*e).insert("Photo3", "test");
    // qDebug() << "Value of \"Photo3\"" << (*e).value("Photo3");

    // QStringList var = settingsVariant["Page Coverage"].toStringList();
    // var.append("Test");
    // settingsVariant["Page Coverage"] = var;

    // auto r = (*settingsVariant).getStringList("Page Coverage");
    // auto r = (*settingsVariant).getStringList("Page Coverage");
    // auto r = (*settingsVariant)("Page Coverage");

    // qDebug() << "L: " << r;
    // qDebug() << "L: " << (*r);
    // if (r == nullptr) {
    //     qDebug() << "NULLPTR";
    //     exit(1);
    // }

    // auto st = (*settingsVariant).getStringList("Page Coverage");

    // (*settingsVariant).getStringList("Page Coverage")->append("Test");

    // QStringList* stringListPtr = settingsVariant["Page
    // Coverage"].value<QStringList*>();

    // if (stringListPtr) {
    //     qDebug() << "ADDING";
    //     stringListPtr->append("newValue1");
    //     stringListPtr->append("newValue2");
    // }

    // qDebug() << (*settingsVariant)["Page Coverage"].toStringList();
    // settings->saveJson();

    auto ret = app.exec();
    return ret;
}
