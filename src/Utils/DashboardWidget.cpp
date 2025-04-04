
#include "Utils/DashboardWidget.h"

#include "ModQMap.cpp"
#include "Utils/FixedLabel.h"
#include "Utils/ModQComboBox.h"

#include <cmath>

#include <QDesktopServices>

void DashboardWidget::calculate() {
    tb->updatePrices();
}

void DashboardWidget::propertyChanged() {
    // qDebug() << "performing Live Calculation";
    if (this->performLiveCalculation) {
        calculate();
    }
}

DashboardWidget::DashboardWidget(QWidget* parent) : QWidget(parent) {
    auto mainlayout = new QVBoxLayout(this);
    auto button_lyt = new QHBoxLayout();

    QPushButton* addNew_btn = new QPushButton("Add New Row");

    QObject::connect(addNew_btn, &QPushButton::clicked, this->tb,
                     &ModQTableWidget::addNewRow);

    QPushButton* remRow_btn = new QPushButton("Remove Selected Rows");

    QObject::connect(remRow_btn, &QPushButton::clicked, this->tb,
                     &ModQTableWidget::deleteSelectedRow);

    QPushButton* settings_btn = new QPushButton("Refresh Config");
    QObject::connect(settings_btn, &QPushButton::clicked, this,
                     &DashboardWidget::openChangeDialog);

    QPushButton* edit_btn = new QPushButton("Open Config");
    QObject::connect(edit_btn, &QPushButton::clicked, this,
                     &DashboardWidget::openConfig);

    button_lyt->addWidget(addNew_btn);
    button_lyt->addWidget(remRow_btn);
    QSpacerItem* sp =
        new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    button_lyt->addSpacerItem(sp);
    button_lyt->addWidget(settings_btn);
    button_lyt->addWidget(edit_btn);

    QObject::connect(this->tb, &ModQTableWidget::totalComputed,
                     [this](int total) {
                         this->label->setText(QString("Price: %1").arg(total));
                     });
    this->tb->addNewRow();

    // QPushButton* calculate_btn = new QPushButton("Calculate");

    // QObject::connect(calculate_btn, &QPushButton::clicked, this,
    //  &DashboardWidget::calculate);

    mainlayout->addLayout(button_lyt);
    mainlayout->addWidget(this->tb);
    mainlayout->addWidget(this->label);
    // mainlayout->addWidget(calculate_btn);
    // mainlayout->addWidget(settings_btn);
    this->setLayout(mainlayout);
}

void DashboardWidget::openChangeDialog() {
    tb->refreshJson();
    // QDialog* changeDialog = new QDialog(this);

    // QVBoxLayout* mainLayout = new QVBoxLayout(this);
    // changeDialog->setLayout(mainLayout);

    // QHBoxLayout* qualityTypeBox = new QHBoxLayout(this);
    // QLabel* qualityTypeLabel = new QLabel();
    // ModQComboBox* qualityTypeCmbx = new ModQComboBox();

    // qualityTypeBox->addWidget(qualityTypeLabel);
    // qualityTypeBox->addWidget(qualityTypeCmbx);

    // mainLayout->addLayout(qualityTypeBox);

    // changeDialog->exec();
}

void DashboardWidget::openConfig() {
    QString filePath = QCoreApplication::applicationDirPath() + "/config.json";
    QDesktopServices::openUrl(QUrl::fromLocalFile(filePath));
}