
#include "DashboardWidget.h"

#include "Utils/FixedLabel.h"
#include "Utils/ModQComboBox.h"
#include "Utils/ModQMap.cpp"

#include <cmath>

void DashboardWidget::calculate() {
    qDebug() << "Called";
    tb->updatePrices();

    // int price = pricePerPage * pageCount_Value * copyCount_Value;
    // std::ostringstream stream;
    // // stream << std::left;
    // stream << std::right << std::setw(20) << "Cost per page:" << std::right
    //        << std::setw(7) << pricePerPage << std::setw(2) << "x"
    //        << "\n"
    //        << std::right << std::setw(20) << "Number of pages:" << std::right
    //        << std::setw(7) << pageCount_Value << std::setw(2) << "x"
    //        << "\n"
    //        << std::right << std::setw(20) << "Number of copies:" <<
    //        std::right
    //        << std::setw(7) << copyCount_Value << std::setw(2) << "x"
    //        << "\n\n";

    // stream << std::right;
    // stream << std::setw(20) << "Total:" << std::setw(7) << "Php " << price;

    // //
    // this->costBreakdown_txtedit->setText(QString::fromStdString(stream.str()));
}

void DashboardWidget::propertyChanged() {
    qDebug() << "performing Live Calculation";
    if (this->performLiveCalculation) {
        calculate();
    }
}

DashboardWidget::DashboardWidget(QWidget* parent) : QWidget(parent) {
    auto mainlayout = new QVBoxLayout(this);

    QPushButton* addNew_btn = new QPushButton("Add New Row");

    QObject::connect(addNew_btn, &QPushButton::clicked, this->tb,
                     &ModQTableWidget::addNewRow);

    QPushButton* remRow_btn = new QPushButton("Remove Selected Rows");

    QObject::connect(remRow_btn, &QPushButton::clicked, this->tb,
                     &ModQTableWidget::deleteSelectedRow);

    QObject::connect(this->tb, &ModQTableWidget::totalComputed,
                     [this](int total) {
                         this->label->setText(QString("Price: %1").arg(total));
                     });
    this->tb->addNewRow();

    QPushButton* calculate_btn = new QPushButton("Calculate");

    QObject::connect(calculate_btn, &QPushButton::clicked, this,
                     &DashboardWidget::calculate);

    mainlayout->addWidget(addNew_btn);
    mainlayout->addWidget(remRow_btn);
    mainlayout->addWidget(this->tb);

    mainlayout->addWidget(this->label);

    mainlayout->addWidget(calculate_btn);

    // +++++++++++++++++ END TABLE WIDGET +++++++++++++++++++++

    // +++++++++++++++++ START COMMENTS +++++++++++++++++++++++

    // // Content Type
    // auto contentType_lbl = new FixedLabel("Content Type: ");

    // auto contentType_cmbx = new ModQComboBox(&(this->contentType_Value));
    // contentType_cmbx->populate(contentType_Map.getKeys(), 2)

    // auto contentType_lyt = new QHBoxLayout();
    // // contentType_lyt->setContentsMargins(0, 0, 0, 0);
    // // contentType_lyt->setSpacing(0);

    // contentType_lyt->addWidget(contentType_lbl);
    // contentType_lyt->addWidget(contentType_cmbx, 1);

    // // Photo Coverage
    // auto photoCoverage_lbl = new FixedLabel("Photo Coverage: ");

    // auto photoCoverage_cmbx = new
    // ModQComboBox(&(this->photoCoverage_Value));
    // photoCoverage_cmbx->populate(photoCoverage_Options, 0);

    // auto photoCoverage_lyt = new QHBoxLayout();
    // photoCoverage_lyt->addWidget(photoCoverage_lbl);
    // photoCoverage_lyt->addWidget(photoCoverage_cmbx, 1);

    // // Quality Type
    // auto qualityType_lbl = new FixedLabel("Quality Type: ");

    // auto qualityType_cmbx = new ModQComboBox(&(this->qualityType_Value));
    // qualityType_cmbx->populate(qualityType_Map.getKeys(), 1);

    // auto qualityCoverage_lyt = new QHBoxLayout();
    // qualityCoverage_lyt->addWidget(qualityType_lbl);
    // qualityCoverage_lyt->addWidget(qualityType_cmbx, 1);

    // // Paper Size
    // auto paperSize_lbl = new FixedLabel("Paper Size: ");

    // auto paperSize_cmbx = new ModQComboBox(&(this->paperSize_Value));
    // paperSize_cmbx->populate(paperSize_Map.getKeys(), 1);

    // auto paperSize_lyt = new QHBoxLayout();
    // paperSize_lyt->addWidget(paperSize_lbl);
    // paperSize_lyt->addWidget(paperSize_cmbx, 1);

    // // Paper Type
    // auto paperType_lbl = new FixedLabel("Paper Type: ");

    // auto paperType_cmbx = new ModQComboBox(&(this->paperType_Value));
    // paperType_cmbx->populate(paperType_Map.getKeys(), 0);

    // auto paperType_lyt = new QHBoxLayout();
    // paperType_lyt->addWidget(paperType_lbl);
    // paperType_lyt->addWidget(paperType_cmbx, 1);

    // auto liveCalculation_chkbx = new QCheckBox("Live Calculation", this);
    // QObject::connect(liveCalculation_chkbx, &QCheckBox::toggled,
    //                  [this](bool state) {
    //                      calculate();
    //                      this->performLiveCalculation = state;
    //                      qDebug() << state;
    //                  });
    // liveCalculation_chkbx->toggle();

    // // Page Count
    // auto pageCount_lbl = new FixedLabel("Pages: ");
    // QObject::connect(this->pageCount_spnbx, &QSpinBox::valueChanged,
    //                  [this](int value) { this->pageCount_Value = value;
    //                  });
    // this->pageCount_spnbx->setValue(1);

    // auto pageCount_lyt = new QHBoxLayout();
    // pageCount_lyt->addWidget(pageCount_lbl);
    // pageCount_lyt->addWidget(pageCount_spnbx);

    // // Copies
    // auto copyCount_lbl = new FixedLabel("Copies: ");
    // QObject::connect(this->copyCount_spnbx, &QSpinBox::valueChanged,
    //                  [this](int value) { this->copyCount_Value = value;
    //                  });
    // this->copyCount_spnbx->setValue(1);

    // auto copyCount_lyt = new QHBoxLayout();
    // copyCount_lyt->addWidget(copyCount_lbl);
    // copyCount_lyt->addWidget(copyCount_spnbx);

    // label->setMinimumSize(140, 50);
    // label->setStyleSheet(
    //     "border-width: 1px; border-style: solid; border-color: black;");

    // auto calculate_btn = new QPushButton("Calculate");
    // QObject::connect(calculate_btn, &QPushButton::clicked, this,
    // &calculate);

    // // auto costBreakdown_txtedit = new QTextEdit();

    // QFont f("unexistent");
    // f.setStyleHint(QFont::Monospace);
    // this->costBreakdown_txtedit->setFont(f);

    // auto showDetailed_btn = new QPushButton("Show Detailed Breakdown");
    // QObject::connect(showDetailed_btn, &QPushButton::clicked, [this]() {
    //     this->costBreakdown_txtedit->setHidden(
    //         !this->costBreakdown_txtedit->isHidden());
    // });

    // auto spacer = new QSpacerItem(10, 10);

    // mainlayout->addLayout(contentType_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addLayout(photoCoverage_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addLayout(qualityCoverage_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addLayout(paperSize_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addLayout(paperType_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addLayout(pageCount_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addLayout(copyCount_lyt);
    // // mainlayout->addSpacerItem(spacer);

    // mainlayout->addWidget(liveCalculation_chkbx);

    // mainlayout->addStretch();
    // mainlayout->addWidget(label, 0, Qt::AlignCenter);
    // mainlayout->addSpacing(30);

    // mainlayout->addWidget(calculate_btn);
    // mainlayout->addWidget(showDetailed_btn);
    // mainlayout->addWidget(costBreakdown_txtedit);

    // // mainlayout->setContentsMargins(5, 1, 5, 1);
    // mainlayout->setSpacing(0);

    // +++++++++++++++++ END COMMENTS +++++++++++++++++++++

    this->setLayout(mainlayout);

    // this->contentType_Notifier =
    //     contentType_Value.addNotifier(std::function<void()>(
    //         std::bind(DashboardWidget::propertyChanged, this)));
    // this->photoCoverage_Notifier =
    //     photoCoverage_Value.addNotifier(std::function<void()>(
    //         std::bind(DashboardWidget::propertyChanged, this)));
    // this->qualityType_Notifier =
    //     qualityType_Value.addNotifier(std::function<void()>(
    //         std::bind(DashboardWidget::propertyChanged, this)));
    // this->paperSize_Notifier =
    //     paperSize_Value.addNotifier(std::function<void()>(
    //         std::bind(DashboardWidget::propertyChanged, this)));
    // this->paperType_Notifier =
    //     paperType_Value.addNotifier(std::function<void()>(
    //         std::bind(DashboardWidget::propertyChanged, this)));
}
