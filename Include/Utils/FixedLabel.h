#ifndef HELPER_FIXEDLABEL
#define HELPER_FIXEDLABEL

#include <QLabel>
#include <QString>
#include <QTextFormat>

class FixedLabel : public QLabel {
    Q_OBJECT

   public:
    FixedLabel(const QString& text);
};

#endif  // HELPER_FIXEDLABEL