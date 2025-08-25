#ifndef HELPER_MODQSPINBOX
#define HELPER_MODQSPINBOX

#include <QSpinBox>

class ModQSpinBox : public QSpinBox {
    Q_OBJECT

   signals:
    void rowChanged(int row);

   public slots:
    void updateProperty(int num);

   private:
    int row;
    int reference_property;

   public:
    ModQSpinBox(int row);
};

#endif  // HELPER_MODQSPINBOX