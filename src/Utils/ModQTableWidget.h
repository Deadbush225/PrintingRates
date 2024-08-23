#ifndef UTILS_MODQTABLEWIDGET
#define UTILS_MODQTABLEWIDGET
#include <QtCore/QProperty>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QTableWidget>
#include <QtWidgets/QLabel>

#include <QtCore/QDebug>

#include "ModQComboBox.h"
#include "ModQMap.h"
#include "ModQSpinBox.h"

class ModQTableWidget : public QTableWidget {
    Q_OBJECT

   signals:
    void totalComputed(int total);

   private:
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
    int calculatePriceFromRow(int row);

    int updateRowPrice(int row);

    int updateTotal();

    void addNewRow();
    void deleteSelectedRow();
};

#endif // UTILS_MODQTABLEWIDGET