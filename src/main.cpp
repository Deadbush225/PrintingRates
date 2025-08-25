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

#include "Utils/DashboardWidget.h"
#include "Utils/ModOrderedMap.h"

#include <boost/log/trivial.hpp>

#include <boost/log/expressions.hpp>
#include <boost/log/sinks/text_file_backend.hpp>
#include <boost/log/support/date_time.hpp>
#include <boost/log/utility/setup/common_attributes.hpp>
#include <boost/log/utility/setup/file.hpp>

Q_DECLARE_METATYPE(ModOrderedMap<QString>)

void setupLogger() {
    boost::log::add_common_attributes();
    boost::log::formatter fmt =
        boost::log::expressions::stream
        << "[" << boost::log::expressions::attr<unsigned int>("LineID") << "]"
        << "["
        << boost::log::expressions::format_date_time<boost::posix_time::ptime>(
               "TimeStamp", "%Y-%m-%d %H:%M:%S")
        << "]"
        << "[" << boost::log::trivial::severity << "] "
        << boost::log::expressions::smessage;

    auto execPath = QApplication::applicationDirPath();
    auto logFilePath = execPath + "/sample.log";

    auto sink = boost::log::add_file_log(
        boost::log::keywords::file_name = logFilePath.toStdString(),
        boost::log::keywords::rotation_size =
            10 * 1024 * 1024,  // Rotate files after 10MB
        boost::log::keywords::auto_flush = true);

    sink->set_formatter(fmt);

    boost::log::trivial::severity_level logLevel = boost::log::trivial::info;
}

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
    setupLogger();

    BOOST_LOG_TRIVIAL(info) << "This is an info message.";
    BOOST_LOG_TRIVIAL(debug) << "Debugging is fun!";
    BOOST_LOG_TRIVIAL(error) << "Oops, an error!";

    qRegisterMetaType<ModOrderedMap<QString>>("ModOrderedMap<QString>");

    auto app = QApplication(argc, arg);

    setupDarkTheme();

    auto w = DashboardWidget();
    w.show();

    return app.exec();
}
