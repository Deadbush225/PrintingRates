#include "Utils/ModQTableWidget.h"
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

    qDebug() << tableData->length();

    QString m_contentType_Value = tableData->at(row).contentType;
    QString m_photoCoverage_Value = tableData->at(row).photoCoverage;
    QString m_qualityType_Value = tableData->at(row).qualityType;
    QString m_paperSize_Value = tableData->at(row).paperSize;
    QString m_paperType_Value = tableData->at(row).paperType;
    int m_pageCount_Value = tableData->at(row).pageCount;
    int m_copyCount_Value = tableData->at(row).copyCount;

    int price = 0;

    if (m_photoCoverage_Value == "") {  // if this is empty then probably all is
        return 0;                       // empty, for premature calculation
    }

    ModOrderedMap<QVariant>* ContentType =
        (*m_settings).getDict("Content Type");

    QStringList* PageCoverage = (*m_settings).getStringList("Page Coverage");

    ModOrderedMap<QVariant>* QualityType =
        (*m_settings).getDict("Quality Type");

    ModOrderedMap<QVariant>* PaperSize = (*m_settings).getDict("Paper Size");

    ModOrderedMap<QVariant>* PaperType = (*m_settings).getDict("Paper Type");

    int contentType_Value =
        (*ContentType)[m_contentType_Value].value<QList<int>>()
            [(*PageCoverage).indexOf(m_photoCoverage_Value)];

    double qualityType_Value =
        (*QualityType)[m_qualityType_Value].value<double>();

    double paperSize_Value = (*PaperSize)[m_paperSize_Value].value<double>();

    int paperType_Value = (*PaperType)[m_paperType_Value].toInt();

    /* ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ */
    /*                          Calculation                        */
    /* ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ */

    int pricePerPage =
        ceil(contentType_Value * qualityType_Value * paperSize_Value +
             paperType_Value);

    qDebug() << contentType_Value << " * " << qualityType_Value << " * "
             << paperSize_Value << " + " << paperType_Value << " = "
             << pricePerPage;

    price = pricePerPage * m_pageCount_Value * m_copyCount_Value;

    qDebug() << pricePerPage << " * " << m_pageCount_Value << " * "
             << m_copyCount_Value << " = " << price << "\n";

    // this->updatePrices();

    return price;
}

int ModQTableWidget::updateRowPrice(int row) {
    QWidget* widget = this->cellWidget(row, 0);
    if (!widget) {
        qWarning() << "No widget found in cell (" << row << ", 0).";
        return 0;
    }

    RowData rowData;
    rowData.contentType =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 0))->currentText();
    rowData.photoCoverage =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 1))->currentText();
    rowData.qualityType =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 2))->currentText();
    rowData.paperSize =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 3))->currentText();
    rowData.paperType =
        dynamic_cast<ModQComboBox*>(this->cellWidget(row, 4))->currentText();
    rowData.pageCount =
        dynamic_cast<ModQSpinBox*>(this->cellWidget(row, 5))->value();
    rowData.copyCount =
        dynamic_cast<ModQSpinBox*>(this->cellWidget(row, 6))->value();

    if (row < tableData->length()) {
        (*tableData)[row] = rowData;
    } else {
        tableData->insert(row, rowData);
    }

    qDebug() << row;
    qDebug() << tableData;

    // qDebug() << "Calculating row" << row;
    int price = this->calculatePriceFromRow(row);

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
        total +=
            dynamic_cast<QLabel*>(this->cellWidget(row, 7))->text().toInt();
        // qDebug() << total;
    }

    emit totalComputed(total);

    return total;
}

ModQTableWidget::ModQTableWidget() : QTableWidget() {
    // this->setRowCount(10);
    this->setColumnCount(8);
    this->setHorizontalHeaderLabels(QStringList(
        {"Content type", "Photo Coverage", "Quality Type", "Paper Size",
         "Paper Type", "No. of Pages", "No. of Copies", "Price"}));

    this->setMinimumWidth(800);
    this->setMinimumHeight(300);
    this->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
}

void ModQTableWidget::addRow(int row) {
    if (!m_settings) {
        qCritical() << "m_settings is null!";
        return;
    }

    qDebug() << "Row: " << row;

    // CONTENT TYPE
    auto contentType_cmbx = new ModQComboBox();
    contentType_cmbx->populate((*m_settings).getDict("Content Type")->keys(),
                               row, 2);
    QObject::connect(contentType_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PHOTO COVERAGE
    auto photoCoverage_cmbx = new ModQComboBox();

    photoCoverage_cmbx->populate(*(*m_settings).getStringList("Page Coverage"),
                                 row, 0);
    QObject::connect(photoCoverage_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // QUALITY TYPE
    auto qualityType_cmbx = new ModQComboBox();
    qualityType_cmbx->populate((*m_settings).getDict("Quality Type")->keys(),
                               row, 1);
    QObject::connect(qualityType_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PAPER SIZE
    auto paperSize_cmbx = new ModQComboBox();
    paperSize_cmbx->populate((*m_settings).getDict("Paper Size")->keys(), row,
                             1);
    QObject::connect(paperSize_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PAPER TYPE
    auto paperType_cmbx = new ModQComboBox();
    paperType_cmbx->populate((*m_settings).getDict("Paper Type")->keys(), row,
                             0);
    QObject::connect(paperType_cmbx, &ModQComboBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // PAGE COUNT
    ModQSpinBox* pageCount_spnbx = new ModQSpinBox(row);
    pageCount_spnbx->setValue(1);
    QObject::connect(pageCount_spnbx, &ModQSpinBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    // COPY COUNT
    ModQSpinBox* copyCount_spnbx = new ModQSpinBox(row);
    copyCount_spnbx->setValue(1);
    QObject::connect(copyCount_spnbx, &ModQSpinBox::rowChanged, this,
                     &ModQTableWidget::updateRowPrice);

    QLabel* rowPrice = new QLabel();

    if (tableData->length() > row) {
        qDebug() << "TABLE ROW DATA ALREADY EXISTS";
        RowData rowData = (*tableData)[row];
        contentType_cmbx->setCurrentText(rowData.contentType);
        photoCoverage_cmbx->setCurrentText(rowData.photoCoverage);
        qualityType_cmbx->setCurrentText(rowData.qualityType);
        paperSize_cmbx->setCurrentText(rowData.paperSize);
        paperType_cmbx->setCurrentText(rowData.paperType);
        pageCount_spnbx->setValue(rowData.pageCount);
        copyCount_spnbx->setValue(rowData.copyCount);
        qDebug() << row;
        qDebug() << tableData;
    }

    // LAYOUT
    this->setCellWidget(row, 0, contentType_cmbx);
    this->setCellWidget(row, 1, photoCoverage_cmbx);
    this->setCellWidget(row, 2, qualityType_cmbx);
    this->setCellWidget(row, 3, paperSize_cmbx);
    this->setCellWidget(row, 4, paperType_cmbx);
    this->setCellWidget(row, 5, pageCount_spnbx);
    this->setCellWidget(row, 6, copyCount_spnbx);
    this->setCellWidget(row, 7, rowPrice);

    this->updateRowPrice(row);
}

void ModQTableWidget::addNewRow() {
    // int new_rowCount = this->rowCount() + 1;
    int rowCount = this->rowCount();
    qDebug() << rowCount;

    this->insertRow(rowCount);
    this->addRow(rowCount);
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

void ModQTableWidget::refreshJson() {
    m_settings = settings->LoadJson();

    int rows = rowCount();
    // this->clearContents();
    for (int i = rows; i >= 0; i--) {
        qDebug() << "REMOVING ROW";
        removeRow(i);
    }

    qDebug() << rowCount();
    for (int j = 0; j < rows; j++) {
        insertRow(j);
        addRow(j);
    }
    qDebug() << rowCount();
    // addRow(1);
    // addNewRow();
}