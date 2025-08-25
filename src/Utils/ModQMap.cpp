#include "Utils/ModQMap.h"
// #ifndef MODQMAP_IMPL
// #define MODQMAP_IMPL

template <typename K, typename V>
V& ModQMap<K, V>::operator[](QString key) {
    return (this->m_innerMap)[key];
}

template <typename K, typename V>
QList<K> ModQMap<K, V>::getKeys() {
    return this->m_innerMap.keys();
}

// #endif