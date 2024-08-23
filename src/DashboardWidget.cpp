
#include "DashboardWidget.h"

#include "Utils/FixedLabel.h"
#include "Utils/ModQComboBox.h"
#include "Utils/ModQMap.cpp"

#include <cmath>

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

    button_lyt->addWidget(addNew_btn);
    button_lyt->addWidget(remRow_btn);

    QObject::connect(this->tb, &ModQTableWidget::totalComputed,
                     [this](int total) {
                         this->label->setText(QString("Price: %1").arg(total));
                     });
    this->tb->addNewRow();

    QPushButton* calculate_btn = new QPushButton("Calculate");

    QObject::connect(calculate_btn, &QPushButton::clicked, this,
     &DashboardWidget::calculate);

    mainlayout->addLayout(button_lyt);
    mainlayout->addWidget(this->tb);
    mainlayout->addWidget(this->label);
    mainlayout->addWidget(calculate_btn);
    this->setLayout(mainlayout);
}
