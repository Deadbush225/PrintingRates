#ifndef UTILS_MODQTABLEWIDGET
#define UTILS_MODQTABLEWIDGET

#include <QtCore/QProperty>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QTableWidget>

#include "ModQComboBox.h"
#include "ModQMap.h"
#include "ModQSpinBox.h"

class ModQTableWidget : public QTableWidget {
    Q_OBJECT

   signals:
    void totalComputed(int total);

   private:
    // QProperty<QMap<QString, QList<int>>> contentType_Map_Value;
    // QPropertyNotifier contentType_Map_Notifier;

    // QProperty<QString> contentType_Value;
    // QPropertyNotifier contentType_Notifier;

    // QProperty<QString> photoCoverage_Value;
    // QPropertyNotifier photoCoverage_Notifier;

    // QProperty<QString> qualityType_Value;
    // QPropertyNotifier qualityType_Notifier;

    // QProperty<QString> paperSize_Value;
    // QPropertyNotifier paperSize_Notifier;

    // QProperty<QString> paperType_Value;
    // QPropertyNotifier paperType_Notifier;

    // QProperty<int> pageCount_Value;
    // QPropertyNotifier pageCount_Notifier;

    // QProperty<int> copyCount_Value;
    // QPropertyNotifier copyCount_Notifier;

    ModQMap<QString, QList<int>> contentType_Map = {};
    // QProperty<QMap<QString, QList<int>>> contentType_Map;
    QStringList photoCoverage_Options;
    ModQMap<QString, double> qualityType_Map;
    ModQMap<QString, double> paperSize_Map;
    ModQMap<QString, int> paperType_Map;

    /* data */
   public:
    ModQTableWidget(/* args */);
    virtual ~ModQTableWidget() = default;

    void updatePrices();
    int calculateRow(int row);

    int updateRowPrice(int row);

    int updateTotal();

    void addNewRow();
    void deleteSelectedRow();
};

#endif