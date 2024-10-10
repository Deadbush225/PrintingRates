#include "Settings.h"
#include <vector>

#include <QJsonDocument>
#include <QJsonObject>
#include <QSettings>
#include <QFile>
#include <QIODevice>
#include <QVariant>
#include <type_traits>

Q_DECLARE_METATYPE(ModQList<int>)

bool readJsonFile(QIODevice &device, QSettings::SettingsMap &map) {
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(device.readAll(), &error);
    if (error.error != QJsonParseError::NoError) {
        return false;
    }
    map = doc.toVariant().toMap();
    return true;
}

bool writeJsonFile(QIODevice &device, const QSettings::SettingsMap &map) {
    QJsonDocument doc = QJsonDocument::fromVariant(QVariant::fromValue(map));
    device.write(doc.toJson());
    return true;
}


Settings::Settings() {
    const QSettings::Format JsonFormat = QSettings::registerFormat("json", readJsonFile, writeJsonFile);

    settings = new ModQSettings("config.json", JsonFormat);

    auto CT_Photo_default = ModQList<int>({1, 2, 3, 4, 5, 5});
    auto CT_Text_default = ModQList<int>({5, 5, 4, 4, 3, 3});
    auto CT_TextWPhoto_default = ModQList<int>({8, 7, 6, 5, 4, 4});

    qDebug() << "TEST\n" << CT_Photo_default;

    CT_Photo = settings->value<ModQList<int>>("ContentType/Photo", QVariant::fromValue(CT_Photo_default));

    qDebug() << CT_Photo << "\nTEST\n";

    CT_Text = settings->value<ModQList<int>>("ContentType/Text", QVariant::fromValue(CT_Photo_default));
    CT_TextWPhoto = settings->value<ModQList<int>>("ContentType/TextwPhoto", QVariant::fromValue(CT_Photo_default));

    this->contentType_Map["Photo"] = CT_Photo;
    this->contentType_Map["Text"] = CT_Text;
    this->contentType_Map["Text \\w Photo"] = CT_TextWPhoto;

    auto PC_OPtions_default = QStringList({"Full", "5/6", "4/6", "Half", "2/6", "1/6"});

    PC_Options = settings->value<QStringList>("PC/Options", QVariant::fromValue(PC_OPtions_default));
    PC_Options.append("TEST");
    qDebug() << PC_Options;

    settings->setValue("PC/Options", PC_Options);

    this->photoCoverage_Options = PC_Options;

    this->qualityType_Map["Draft"] = settings->value("Draft", 0.4).toInt();
    this->qualityType_Map["Standard"] = 1;
    this->qualityType_Map["Standard-Vivid"] = 1.3;
    this->qualityType_Map["High"] = 1.7;

    this->paperSize_Map["Short"] = 1;
    this->paperSize_Map["A4"] = 1.1;
    this->paperSize_Map["Long"] = 1.2;

    this->paperType_Map["Plain"] = 0;
    this->paperType_Map["Colored Paper"] = 1;
    this->paperType_Map["Sticker Paper"] = 10;
    this->paperType_Map["Matte"] = 8;
    this->paperType_Map["Ultra Glossy"] = 25;
    this->paperType_Map["Premium Glossy"] = 25;
    this->paperType_Map["Premium Semigloss"] = 25;
    this->paperType_Map["Photo Paper Glossy"] = 20;

    settings->setValue("PaperType/Plain", 0);
    settings->setValue("ContentType/Photo", CT_Photo.toString()            );
}

template <typename T>
QString ModQList<T>::toString() {
    QString string;

    for (auto i = this->begin(), j = this->end(); i!=j ;i++) {
        string += QVariant(*i).toString();

        if (i + 1 != j) {
            string += ", ";
        }
    }
    return string;
}

template <typename T>
ModQList<int> ModQList<T>::fromString(const QString &string) {
    qDebug() << "FROM STRING WITH INT";

    ModQList<int> stringList = ModQList<QString>::fromString(string);

    ModQList<int> outputList;
    for (auto i = stringList.begin(), j = stringList.end(); i!=j; i++) {
        qDebug() << *i;
        outputList.append(QVariant(*i).toInt());
    }

    return outputList;
}

template <>
ModQList<int> ModQList<QString>::fromString(const QString &string) {
    qDebug() << "FROM STRING WITH STRING";
    qDebug() << string;

    QStringList stringList = string.split(", ", Qt::SkipEmptyParts);

    qDebug() << stringList;

    ModQList<int> result;
    for (const QString &str : stringList) {
        qDebug() << str;
        result.append(str.toInt());
    }

    return result;
}

// Compile time checker
template<typename T, typename = void>
struct is_iterable : std::false_type {};

template<typename T>
struct is_iterable<T, std::void_t< // Final check if we can map each value to void
    decltype(std::begin(std::declval<T&>()) != std::end(std::declval<T&>())), // Check if begin and end exist
    decltype(++std::declval<decltype(std::begin(std::declval<T&>()))&>()),    // Check if we can increment the iterator
    decltype(*std::begin(std::declval<T&>()))>> : std::true_type {};          // Check if we can dereference the iterator

template<typename T>
T ModQSettings::value(const QString &key, const QVariant &defaultValue)
{
    auto value = QSettings::value(key);


    if (!value.isValid()) {
        qDebug() << "INVALID";
     //return ModQList<int>::fromString(defaultValue.toString());
        qDebug() << defaultValue.value<T>();
        return defaultValue.value<T>();
    }

    qDebug() << "VALID";
    if constexpr (std::is_same<T, QStringList>::value) {
        return value.toStringList();
    } /*else if (std::is_same<T, int>::value) {
        return value.toInt();
    } */else if constexpr (is_iterable<T>::value) {
        return ModQList<int>::fromString(value.toString());
    }
}

