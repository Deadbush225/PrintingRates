#include "Utils/FixedLabel.h"

FixedLabel::FixedLabel(const QString& text) : QLabel(text) {
    this->setMinimumWidth(110);

    this->setStyleSheet("font-weight: bold; font-size: 30px");
    // this->setMaximumHeight(20);
}