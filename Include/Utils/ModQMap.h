#ifndef HELPER_MODQMAP
#define HELPER_MODQMAP

#include <QDebug>
#include <QList>
#include <QString>
#include <QStringList>

// #include "ModQMap_impl.h"

template <typename K, typename V>
class ModQMap {
    // Q_OBJECT

   public:
    ModQMap() = default;
    V& operator[](QString key);
    QList<K> getKeys();

   private:
    QMap<K, V> m_innerMap;
};

#endif  // HELPER_MODQMAP