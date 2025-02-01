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

#include "Include/Utils/DashboardWidget.h"
#include "Include/Utils/ModOrderedMap.h"

Q_DECLARE_METATYPE(ModOrderedMap<QString>)

void setupDarkTheme() {
    QApplication::setStyle("Fusion");
    QApplication::setWindowIcon(QIcon(":/Icons/Printing Rates.png"));

    // Now use a palette to switch to dark colors:
    QPalette* dark_palette = new QPalette();
    dark_palette->setColor(QPalette::Window, QColor(53, 53, 53));
    dark_palette->setColor(QPalette::WindowText, Qt::white);
    dark_palette->setColor(QPalette::Base, QColor(35, 35, 35));
    dark_palette->setColor(QPalette::AlternateBase, QColor(53, 53, 53));
    dark_palette->setColor(QPalette::ToolTipBase, QColor(25, 25, 25));
    dark_palette->setColor(QPalette::ToolTipText, Qt::white);
    dark_palette->setColor(QPalette::Text, Qt::white);
    dark_palette->setColor(QPalette::Button, QColor(53, 53, 53));
    dark_palette->setColor(QPalette::ButtonText, Qt::white);
    dark_palette->setColor(QPalette::BrightText, Qt::red);
    dark_palette->setColor(QPalette::Link, QColor(42, 130, 218));
    dark_palette->setColor(QPalette::Highlight, QColor(42, 130, 218));
    dark_palette->setColor(QPalette::HighlightedText, QColor(35, 35, 35));
    dark_palette->setColor(QPalette::Active, QPalette::Button,
                           QColor(53, 53, 53));
    dark_palette->setColor(QPalette::Disabled, QPalette::ButtonText,
                           Qt::darkGray);
    dark_palette->setColor(QPalette::Disabled, QPalette::WindowText,
                           Qt::darkGray);
    dark_palette->setColor(QPalette::Disabled, QPalette::Text, Qt::darkGray);
    dark_palette->setColor(QPalette::Disabled, QPalette::Light,
                           QColor(53, 53, 53));
    QApplication::setPalette(*dark_palette);
}

int main(int argc, char* arg[]) {
    qRegisterMetaType<ModOrderedMap<QString>>("ModOrderedMap<QString>");

    auto app = QApplication(argc, arg);

    setupDarkTheme();

    auto w = DashboardWidget();
    w.show();

    return app.exec();
}
