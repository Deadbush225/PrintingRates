#ifndef MAIN_M
#define MAIN_M

#include <iostream>
#include <iomanip>
#include <functional>

#include "Utils/ModQComboBox.h"
#include "Utils/ModQMap.h"
#include "Utils/FixedLabel.h"

#include <QWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QComboBox>
#include <QStringList>
#include <QList>
#include <QMap>
#include <QString>
#include <QPushButton>
#include <QSpacerItem>
#include <QLabel>
#include <Qt>
#include <QObject>
#include <QDebug>
#include <QCheckBox>
#include <QProperty>
#include <QPropertyNotifier>
#include <QSizePolicy>
#include <QSpinBox>
#include <QTextEdit>
#include <QFont>

// template<typename N>


class DashboardWidget : public QWidget {
    Q_OBJECT
    // Q_PROPERTY(QString contentType_Value READ contentType WRITE setContentType NOTIFY valueChanged)

    public:
        DashboardWidget(QWidget* parent = nullptr);
        virtual ~DashboardWidget() = default;
        
        void propertyChanged();

    public slots:
        void calculate();
    
    // signals:
        // void valueChanged(QString new_value);

    private:

        QProperty<QString> contentType_Value;
        QPropertyNotifier contentType_Notifier;

        QProperty<QString> photoCoverage_Value;
        QPropertyNotifier photoCoverage_Notifier;

        QProperty<QString> qualityType_Value;
        QPropertyNotifier qualityType_Notifier;

        QProperty<QString> paperSize_Value;
        QPropertyNotifier paperSize_Notifier;

        QProperty<QString> paperType_Value;
        QPropertyNotifier paperType_Notifier;

        QProperty<int> pageCount_Value;
        QPropertyNotifier pageCount_Notifier;

        QProperty<int> copyCount_Value;
        QPropertyNotifier copyCount_Notifier;

        QProperty<QString> costBreakdown;

        ModQMap<QString, QList<int>> contentType_Map;
        QStringList photoCoverage_Options;
        ModQMap<QString, double> qualityType_Map;
        ModQMap<QString, double> paperSize_Map;
        ModQMap<QString, int> paperType_Map;

        bool performLiveCalculation;

        QLabel* label = new QLabel("Price: ");
        QSpinBox* pageCount_spnbx = new QSpinBox();
        QSpinBox* copyCount_spnbx = new QSpinBox();
        QTextEdit* costBreakdown_txtedit = new QTextEdit();

        QProperty<QString> costBreakdown_Value;
        QPropertyNotifier costBreakdown_Notifier;
};

#endif // MAIN_M