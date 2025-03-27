#include "Utils/ModQSpinBox.h"

ModQSpinBox::ModQSpinBox(int row) {
    // data validation
    this->setMinimum(1);
    this->setMaximum(200);

    // properties
    this->row = row;
    QObject::connect(this, &valueChanged, this, &updateProperty);
}

void ModQSpinBox::updateProperty(int i) {
    // qDebug() << "Value changed: " << i << "\n";

    this->reference_property = i;
    emit rowChanged(this->row);
}
