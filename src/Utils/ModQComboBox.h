#ifndef HELPER_MODQCOMBOBOX
#define HELPER_MODQCOMBOBOX

#include <QComboBox>
#include <QString>
#include <QStringList>
#include <QProperty>

class ModQComboBox : public QComboBox {
    Q_OBJECT

    private:
        // QString current_value;
        QProperty<QString>* reference_property;

    public:
        ModQComboBox(QProperty<QString>* var_cont);
        void populate(const QStringList &items, int default_index = 0);

    public slots:
        void updateProperty(QString string);
};

#endif // HELPER_MODQCOMBOBOX