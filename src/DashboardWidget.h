#ifndef MAIN_M
#define MAIN_M

#include <functional>
#include <iomanip>
#include <iostream>

#include "Utils/FixedLabel.h"
#include "Utils/ModQComboBox.h"
#include "Utils/ModQMap.h"
#include "Utils/ModQTableWidget.h"

#include <QCheckBox>
#include <QComboBox>
#include <QDebug>
#include <QDialog>
#include <QFont>
#include <QHBoxLayout>
#include <QLabel>
#include <QList>
#include <QMap>
#include <QObject>
#include <QProperty>
#include <QPropertyNotifier>
#include <QPushButton>
#include <QSettings>
#include <QSizePolicy>
#include <QSpacerItem>
#include <QSpinBox>
#include <QString>
#include <QStringList>
#include <QTextEdit>
#include <QVBoxLayout>
#include <QWidget>
#include <Qt>

class DashboardWidget : public QWidget {
    Q_OBJECT

   public:
    DashboardWidget(QWidget* parent = nullptr);
    virtual ~DashboardWidget() = default;

    void propertyChanged();
    ModQTableWidget* tb = new ModQTableWidget();

   public slots:
    void calculate();
    void openChangeDialog();

   private:
    ModQMap<QString, QList<int>> contentType_Map;
    QStringList photoCoverage_Options;
    ModQMap<QString, double> qualityType_Map;
    ModQMap<QString, double> paperSize_Map;
    ModQMap<QString, int> paperType_Map;

    bool performLiveCalculation;

    QLabel* label = new FixedLabel("Price: 0");
    QSpinBox* pageCount_spnbx = new QSpinBox();
    QSpinBox* copyCount_spnbx = new QSpinBox();
    QTextEdit* costBreakdown_txtedit = new QTextEdit();

    QProperty<QString> costBreakdown;
    QProperty<QString> costBreakdown_Value;
    QPropertyNotifier costBreakdown_Notifier;
};

#endif  // MAIN_M
