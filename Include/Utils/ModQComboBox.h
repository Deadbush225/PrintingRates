#ifndef HELPER_MODQCOMBOBOX
#define HELPER_MODQCOMBOBOX

#include <QComboBox>
#include <QProperty>
#include <QPropertyNotifier>
#include <QString>
#include <QStringList>

#include <functional>

class ModQComboBox : public QComboBox {
    Q_OBJECT

   signals:
    void rowChanged(int row);

   public slots:
    void updateProperty(QString string);

   private:
    int row;
    QString reference_property;
    // QString current_value;
    // QProperty<QString> reference_property;
    // QPropertyNotifier reference_property_Notifier;

   public:
    ModQComboBox();
    void populate(const QStringList& items, int row, int default_index = 0);
};

#endif  // HELPER_MODQCOMBOBOX