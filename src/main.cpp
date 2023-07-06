// #include <iostream>
#include <QApplication>
#include <QWidget>

#include "DashboardWidget.h"

int main(int argc, char* arg[]) {
    auto app = QApplication(argc, arg);

    auto w = DashboardWidget();
    // auto w = QWidget();
    w.show();
    // w.setStyleSheet(
    // "*{ border: 1px solid black;} QLabel { padding: 0 0 0 0px; }");

    app.exec();
}
