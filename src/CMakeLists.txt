cmake_minimum_required(VERSION 3.16)
project(PrintingRates VERSION 0.1.0)

# file(GLOB_RECURSE HELPER_FILES "/src/HELPER/*.cpp")
# file(GLOB_RECURSE INCLUDE_FILES "*.h")

# Find includes in the build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Turn on automatic invocation of the MOC, UIC & RCC
set(CMAKE_AUTOMOC ON)
# set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(PROJECT_NAME PrintingRates)

find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt6 REQUIRED COMPONENTS Core)
qt_standard_project_setup()

file(GLOB_RECURSE UTILS "*.cpp")
file(GLOB_RECURSE HEADER "*.h")
file(GLOB_RECURSE InstallerConfigs "../config/*.*")
file(GLOB_RECURSE Packages "../packages/*.*")

set(SOURCE_FILES
    ${UTILS}
    ${HEADER}
    ${InstallerConfigs}
    ${Packages}
    )

# set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/resources/photosurface.rc")

# qt_add_executable(photosurfaceexample main.cpp ${app_icon_resource_windows})
# add_executable(PrintingRates main.cpp DashboardWidget.cpp)
#---

set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/icons/Printing Rates.rc")
add_executable(${PROJECT_NAME} ${SOURCE_FILES} ${app_icon_resource_windows} icons/resource.qrc)
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Printing Rates")
# include_directories("src/Utils" "Utils/")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE true)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE "src/Utils/")
# add_executable(Testsd ${SOURCE_FILES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)


#---
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core)
# target_include_directories(PrintingRates PRIVATE "Utils")

# target_link_libraries(Testsd PRIVATE Qt6::Widgets)
# target_link_libraries(Testsd PRIVATE Qt6::Core)

# set(CPACK_PROJECT_NAME ${PROJECT_NAME})
# set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
# include(CPack)

### --- DEFAULT
# message(install_bindir="${CMAKE_INSTALL_BINDIR}")

# install(TARGETS ${PROJECT_NAME} BUNDLE DESTINATION . RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# qt_generate_deploy_app_script(
#     TARGET ${PROJECT_NAME} OUTPUT_SCRIPT deploy_script NO_TRANSLATIONS
# )

# message(deploy_script="${deploy_script}")

# install(SCRIPT ${deploy_script})

### ----

if(APPLE)
    set(executable_path "$<TARGET_FILE_NAME:${PROJECT_NAME}>.app")
elseif(WIN32)
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
else()
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
    set(STATUS "UNIX Based SYSTEM")
endif()

set(deploy_script "${CMAKE_CURRENT_BINARY_DIR}/deploy_${PROJECT_NAME}.cmake")

file(GENERATE OUTPUT ${deploy_script} CONTENT "
include(\"${QT_DEPLOY_SUPPORT}\")
qt_deploy_runtime_dependencies(
    EXECUTABLE \"${executable_path}\"
    PLUGINS_DIR bin
)"
)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
install(SCRIPT ${deploy_script})
