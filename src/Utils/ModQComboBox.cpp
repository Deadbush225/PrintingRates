#include "Utils/ModQComboBox.h"

ModQComboBox::ModQComboBox() {
    // this->reference_property = QProperty<QString>{};

    // this->reference_property_Notifier = this->reference_property.addNotifier(
    //     std::function<void()>(std::bind(ModQComboBox::updateProperty,
    //     this)));

    // this->reference_property_Notifier =
    //     this->reference_property->addNotifier(std::function);

    QObject::connect(this, &currentTextChanged, this, &updateProperty);
}

void ModQComboBox::populate(const QStringList& items,
                            int row,
                            int default_index /* = 0 */) {
    this->row = row;
    this->addItems(items);
    this->setCurrentIndex(default_index);
}

void ModQComboBox::updateProperty(QString string) {
    // this->current_value = string;
    // qDebug() << "Value changed: " << string << "\n";
    // *(this->reference_property) = string;
    this->reference_property = string;
    emit rowChanged(this->row);
}
