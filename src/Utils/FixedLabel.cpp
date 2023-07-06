#include "FixedLabel.h"

FixedLabel::FixedLabel(const QString& text) : QLabel(text) {
    this->setMinimumWidth(110);
    // this->setMaximumHeight(20);
}