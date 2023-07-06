#ifndef UTILS_MODQTABLEWIDGET
#define UTILS_MODQTABLEWIDGET

#include <QtWidgets/QTableWidget>

class ModQTableWidget : public QTableWidget {
   private:
    /* data */
   public:
    ModQTableWidget(/* args */);
    virtual ~ModQTableWidget() = default;
};

#endif