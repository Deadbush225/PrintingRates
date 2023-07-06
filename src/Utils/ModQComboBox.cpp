#include "ModQComboBox.h"

ModQComboBox::ModQComboBox(QProperty<QString>* reference_property) {
    this->reference_property = reference_property;

    QObject::connect(this, &currentTextChanged, this, &updateProperty);
}

void ModQComboBox::populate(const QStringList &items, int default_index /* = 0 */) {
    this->addItems(items);
    this->setCurrentIndex(default_index);
}

void ModQComboBox::updateProperty(QString string) {
    // this->current_value = string;
    qDebug() << "Value changed: " << string << "\n";
    *(this->reference_property) = string;
}