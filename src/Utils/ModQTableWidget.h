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
#include "Settings.h"

class ModQTableWidget : public QTableWidget {
    Q_OBJECT

   signals:
    void totalComputed(int total);

    /* data */
   public:
    ModQTableWidget(/* args */);
    virtual ~ModQTableWidget() = default;

    Settings* settings = new Settings();

    void updatePrices();
    int calculatePriceFromRow(int row);

    int updateRowPrice(int row);

    int updateTotal();

    void addNewRow();
    void deleteSelectedRow();
};

#endif // UTILS_MODQTABLEWIDGET
