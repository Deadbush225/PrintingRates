#include "ModQTableWidget.h"
#include "ModQMap.cpp"  // for the template

void ModQTableWidget::updatePrices() {
    int rowCount = this->rowCount();
    // int total = 0;

    for (int row = 0; row < rowCount; ++row) {
        int job = this->updateRowPrice(row);
        // total += job;
    }

    // emit totalComputed(total);
}

int ModQTableWidget::calculatePriceFromRow(int row) {
    // qDebug() << "Calculating row..." << row;

    int price = 0;

    QString m_contentType_Value =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 0))->currentText();
    QString m_photoCoverage_Value =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 1))->currentText();

    // qDebug() << "F: " << m_contentType_Value;
    // qDebug() << "F: " << m_photoCoverage_Value;
    // qDebug() << "F: " << this->photoCoverage_Options;
    // qDebug() << "F: "
    //          << this->photoCoverage_Options.indexOf(m_photoCoverage_Value);

    QString m_qualityType_Value =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 2))->currentText();
    QString m_paperSize_Value =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 3))->currentText();
    QString m_paperType_Value =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 4))->currentText();
    int m_pageCount_Value =
        dynamic_cast<ModQSpinBox*>(this->cellWidget(row, 5))->value();
    int m_copyCount_Value =
        dynamic_cast<ModQSpinBox*>(this->cellWidget(row, 6))->value();

    // qDebug() << "contentType_Value";
    // qDebug() << "1" << this->contentType_Map.getKeys();

    int contentType_Value =
        this->settings->contentType_Map[m_contentType_Value]
                             [this->settings->photoCoverage_Options.indexOf(
                                 m_photoCoverage_Value)];

    // qDebug() << "qualityType_Value";
    double qualityType_Value = settings->qualityType_Map[m_qualityType_Value];

    // qDebug() << "paperSize_Value";
    double paperSize_Value = settings->paperSize_Map[m_paperSize_Value];

    // qDebug() << "paperType_Value";
    int paperType_Value = settings->paperType_Map[m_paperType_Value];

    // qDebug() << "pricePerPage";
    int pricePerPage =
        ceil(contentType_Value * qualityType_Value * paperSize_Value +
             paperType_Value);

    price = pricePerPage * m_pageCount_Value * m_copyCount_Value;

    // qDebug() << price;

    // this->updatePrices();

    // return calculated value
    return price;
}

int ModQTableWidget::updateRowPrice(int row) {
    // qDebug() << "Calculating row" << row;
    int price = this->calculatePriceFromRow(row);
    // qDebug() << price;

    QString price_Qstr = QString::number(price);
    QLabel* lbl = dynamic_cast<QLabel*>(this->cellWidget(row, 7));
    lbl->setText(price_Qstr);

    this->updateTotal();

    return price;
}

int ModQTableWidget::updateTotal() {
    int rowCount = this->rowCount();

    int total = 0;

    // qDebug() << "Total: ";

    for (int row = 0; row < rowCount; ++row) {
        // total += this->item(row, 7)->text().toInt();
        total += dynamic_cast<QLabel*>(this->cellWidget(row, 7))->text().toInt();
        // qDebug() << total;
    }

    emit totalComputed(total);

    return total;
}

ModQTableWidget::ModQTableWidget(/* args */) : QTableWidget() {
    // this->setRowCount(10);
    this->setColumnCount(8);
    this->setHorizontalHeaderLabels(QStringList(
        {"Content type", "Photo Coverage", "Quality Type", "Paper Size",
         "Paper Type", "No. of Pages", "No. of Copies", "Price"}));

    this->setMinimumWidth(800);
    this->setMinimumHeight(300);
    this->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    // property checker
    // this->contentType_Map_Notifier = this->contentType_Map.addNotifier(
    //     std::function<void()>(std::bind(ModQTableWidget::mapChange, this)));

    // CONSTANTS
    // MOVE THIS TO SETTINGS MANIPULATOR
    // Settings* settings = new Settings();
}

void ModQTableWidget::addNewRow() {
    int new_rowCount = this->rowCount() + 1;
    int rowCount = this->rowCount();

    // this->setRowCount(new_rowcount);
    this->insertRow(this->rowCount());

    // CONTENT TYPE
    auto contentType_cmbx = new ModQComboBox();
    contentType_cmbx->populate(settings->contentType_Map.getKeys(), rowCount, 2);
    QObject::connect(contentType_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PHOTO COVERAGE
    auto photoCoverage_cmbx = new ModQComboBox();
    photoCoverage_cmbx->populate(settings->photoCoverage_Options, rowCount, 0);
    QObject::connect(photoCoverage_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // QUALITY TYPE
    // auto qualityType_cmbx = new ModQComboBox(&(this->qualityType_Value));
    auto qualityType_cmbx = new ModQComboBox();
    qualityType_cmbx->populate(settings->qualityType_Map.getKeys(), rowCount, 1);
    QObject::connect(qualityType_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PAPER SIZE
    // auto paperSize_cmbx = new ModQComboBox(&(this->paperSize_Value));
    auto paperSize_cmbx = new ModQComboBox();
    paperSize_cmbx->populate(settings->paperSize_Map.getKeys(), rowCount, 1);
    QObject::connect(paperSize_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PAPER TYPE
    // auto paperType_cmbx = new ModQComboBox(&(this->paperType_Value));
    auto paperType_cmbx = new ModQComboBox();
    paperType_cmbx->populate(settings->paperType_Map.getKeys(), rowCount, 0);
    QObject::connect(paperType_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PAGE COUNT
    ModQSpinBox* pageCount_spnbx = new ModQSpinBox(rowCount);
    // QObject::connect(pageCount_spnbx, &QSpinBox::valueChanged,
    //  [this](int value) { this->pageCount_Value = value; });
    pageCount_spnbx->setValue(1);
    QObject::connect(pageCount_spnbx, &ModQSpinBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // COPY COUNT
    ModQSpinBox* copyCount_spnbx = new ModQSpinBox(rowCount);
    // QObject::connect(copyCount_spnbx, &QSpinBox::valueChanged,
    //  [this](int value) { this->copyCount_Value = value; });
    copyCount_spnbx->setValue(1);
    QObject::connect(copyCount_spnbx, &ModQSpinBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // qDebug() << "4" << this->contentType_Map.getKeys();

    QLabel* rowPrice = new QLabel();

    // LAYOUT
    this->setCellWidget(rowCount, 0, contentType_cmbx);
    this->setCellWidget(rowCount, 1, photoCoverage_cmbx);
    this->setCellWidget(rowCount, 2, qualityType_cmbx);
    this->setCellWidget(rowCount, 3, paperSize_cmbx);
    this->setCellWidget(rowCount, 4, paperType_cmbx);
    this->setCellWidget(rowCount, 5, pageCount_spnbx);
    this->setCellWidget(rowCount, 6, copyCount_spnbx);
    this->setCellWidget(rowCount, 7, rowPrice);

    this->updateRowPrice(rowCount);
}

void ModQTableWidget::deleteSelectedRow() {
    QList<int> indexes;

    QModelIndexList selectedRows = this->selectedIndexes();
    for (auto index : selectedRows) {
        indexes.append(index.row());
    }

    std::sort(indexes.begin(), indexes.end());
    // qDebug() << indexes;
    // qDebug() << "Count: " << indexes.count();

    for (int i = indexes.count() - 1; i >= 0; i--) {
        // qDebug() << "Iter: " << i;
        // qDebug() << "Row: " << indexes[i];
        this->removeRow(indexes[i]);
    }

    this->updateTotal();
}

