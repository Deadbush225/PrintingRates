#ifndef UTILS_MODQTABLEWIDGET
#define UTILS_MODQTABLEWIDGET

#include <QtCore/QProperty>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QTableWidget>

#include <QtCore/QDebug>

#include "JsonSettings.h"
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

    JsonSettings* settings = new JsonSettings();
    EVariantMap* m_settings = settings->LoadJson();
    // QVariantMap* mSettings = Jsonsettings->LoadJson();

    // ModQSettings* mSettings = new ModQSettings();

    void updatePrices();
    int calculatePriceFromRow(int row);

    int updateRowPrice(int row);

    int updateTotal();

    void addNewRow();
    void deleteSelectedRow();
};

#endif  // UTILS_MODQTABLEWIDGET
