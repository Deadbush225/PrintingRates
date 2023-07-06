

cmake_minimum_required(VERSION 3.16)
project(PrintingRates VERSION 0.1.0)

# file(GLOB_RECURSE HELPER_FILES "/src/HELPER/*.cpp")
# file(GLOB_RECURSE INCLUDE_FILES "*.h")

# Find includes in the build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Turn on automatic invocation of the MOC, UIC & RCC
set(CMAKE_AUTOMOC ON)
# set(CMAKE_AUTOUIC ON)
# set(CMAKE_AUTORCC ON)

set(PROJECT_NAME PrintingRates)

find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt6 REQUIRED COMPONENTS Core)
qt_standard_project_setup()

file(GLOB_RECURSE UTILS "Utils/*.cpp")


set(SOURCE_FILES
${UTILS}
main.cpp
DashboardWidget.cpp
    # ModQMap.cpp
    # ModQComboBox.cpp
    # FixedLabel.cpp
    )
    
    # add_executable(PrintingRates main.cpp DashboardWidget.cpp)
    #---
add_executable(${PROJECT_NAME} ${SOURCE_FILES})
# include_directories("src/Utils" "Utils/")

# target_include_directories(${PROJECT_NAME} PRIVATE "src/Utils/")
# add_executable(Testsd ${SOURCE_FILES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)


#---
target_link_libraries(PrintingRates PRIVATE Qt6::Widgets)
target_link_libraries(PrintingRates PRIVATE Qt6::Core)
# target_include_directories(PrintingRates PRIVATE "Utils")

# target_link_libraries(Testsd PRIVATE Qt6::Widgets)
# target_link_libraries(Testsd PRIVATE Qt6::Core)

# set(CPACK_PROJECT_NAME ${PROJECT_NAME})
# set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
# include(CPack)
