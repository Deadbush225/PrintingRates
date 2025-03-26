#ifndef UTILS_MODQTABLEWIDGET
#define UTILS_MODQTABLEWIDGET

// #include <QtCore/QProperty>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QTableWidget>

#include <QtCore/QDebug>
#include <QtCore/QList>

#include "JsonSettings.h"
#include "ModQComboBox.h"
#include "ModQMap.h"
#include "ModQSpinBox.h"

struct RowData {
    QString contentType;
    QString photoCoverage;
    QString qualityType;
    QString paperSize;
    QString paperType;
    int pageCount;
    int copyCount;
};

inline QDebug operator<<(QDebug debug, const RowData& rowData) {
    QDebugStateSaver saver(
        debug);  // Ensures the debug state is restored after this function
    debug.nospace() << "RowData("
                    << "ContentType: " << rowData.contentType << ", "
                    << "PhotoCoverage: " << rowData.photoCoverage << ", "
                    << "QualityType: " << rowData.qualityType << ", "
                    << "PaperSize: " << rowData.paperSize << ", "
                    << "PaperType: " << rowData.paperType << ", "
                    << "PageCount: " << rowData.pageCount << ", "
                    << "CopyCount: " << rowData.copyCount << ")";
    return debug;
}

inline QDebug operator<<(QDebug debug, const QList<RowData>* listRowData) {
    QDebugStateSaver saver(debug);
    debug.nospace() << "QList<RowData>(";
    auto row_dat = listRowData->begin();
    while (row_dat != listRowData->end()) {
        qDebug() << *row_dat;
        ++row_dat;
    }
    return debug;
}

class ModQTableWidget : public QTableWidget {
    Q_OBJECT

   signals:
    void totalComputed(int total);

    /* data */
   public:
    ModQTableWidget(/* args */);
    virtual ~ModQTableWidget() = default;

    JsonSettings* settings = new JsonSettings();
    EVariantMap* m_settings = settings->LoadJson();
    // QVariantMap* mSettings = Jsonsettings->LoadJson();
    void refreshJson();

    QList<RowData>* tableData = new QList<RowData>();
    // ModQSettings* mSettings = new ModQSettings();

    void updatePrices();
    int calculatePriceFromRow(int row);

    int updateRowPrice(int row);

    int updateTotal();

    void addNewRow();
    void addRow(int row);
    void deleteSelectedRow();
};

#endif  // UTILS_MODQTABLEWIDGET
