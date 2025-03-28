cmake_minimum_required(VERSION 3.16)
project(PrintingRates VERSION 0.1.0)

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_C_COMPILER_LAUNCHER "ccache")
set(CMAKE_CXX_COMPILER_LAUNCHER "ccache")

set(CMAKE_PREFIX_PATH "D:/Dev/boost_1_87_0")

# Find includes in the build directories
# set(CMAKE_INCLUDE_CURRENT_DIR ON)
include_directories(${CMAKE_SOURCE_DIR}/Include)
message(${CMAKE_SOURCE_DIR}/Include)

# Turn on automatic invocation of the MOC, UIC & RCC
set(CMAKE_AUTOMOC ON)

# set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(PROJECT_NAME PrintingRates)

find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt6 REQUIRED COMPONENTS Core)
qt_standard_project_setup()

file(GLOB_RECURSE UTILS "./src/*.cpp")
file(GLOB_RECURSE HEADER "./Include/*.h")
file(GLOB_RECURSE InstallerConfigs "./config/*.*")
file(GLOB_RECURSE Packages "./packages/*.*")
file(GLOB_RECURSE Scripts "./*.ps1")

set(SOURCE_FILES
    ${HEADER}
    ${UTILS}
    "./src/main.cpp"
    ${InstallerConfigs}
    ${Packages}
    ${Scripts}
)

# set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/resources/photosurface.rc")

# qt_add_executable(photosurfaceexample main.cpp ${app_icon_resource_windows})
# add_executable(PrintingRates main.cpp DashboardWidget.cpp)
# ---
set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/src/icons/Printing Rates.rc")
add_executable(${PROJECT_NAME} ${SOURCE_FILES} ${app_icon_resource_windows} src/icons/resource.qrc)
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Printing Rates")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE true)
endif()

# target_include_directories(${PROJECT_NAME} PRIVATE "src/Utils/")
# # add_executable(Testsd ${SOURCE_FILES})
# target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)
# target_precompile_headers(${PROJECT_NAME} PRIVATE "./Utils/pch.h" "./Utils/FixedLabel.h" "./Utils/ModQComboBox.h" "./Utils/ModQMap.h" "./Utils/ModQSpinBox.h" "./Utils/ModQTableWidget.h")

# ---
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

set(Boost_ROOT D:/Dev/boost_1_87_0/stage)

# add any of these lines to find the BoostConfig.cmake
# set(Boost_DIR D:/Dev/boost_1_87_0/stage/lib/cmake/Boost-1.87.0)
set(CMAKE_PREFIX_PATH ${Boost_ROOT}) # but this looks cleaner

find_package(Boost REQUIRED COMPONENTS log log_setup)

message(Boost_LIBRARIES: ${Boost_LIBRARIES}) # no contents
message(Boost_INCLUDE_DIRS: ${Boost_INCLUDE_DIRS}) # no contents

# find_package(Boost)

# add_executable(${PROJECT_NAME} main.cpp)
if(Boost_FOUND)
    message("Boost Found...")
    target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})

    # target_link_libraries(${PROJECT_NAME} PUBLIC Boost::log Boost::log_setup)
    target_link_libraries(${PROJECT_NAME} PUBLIC Boost::log Boost::log_setup)

    # target_link_libraries(${PROJECT_NAME} PUBLIC ${Boost_LIBRARIES})
endif()

# ## --- DEFAULT
# message(install_bindir="${CMAKE_INSTALL_BINDIR}")

# install(TARGETS ${PROJECT_NAME} BUNDLE DESTINATION . RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

# qt_generate_deploy_app_script(
# TARGET ${PROJECT_NAME} OUTPUT_SCRIPT deploy_script NO_TRANSLATIONS
# )

# message(deploy_script="${deploy_script}")

# install(SCRIPT ${deploy_script})

# ## ----
if(APPLE)
    set(executable_path "$<TARGET_FILE_NAME:${PROJECT_NAME}>.app")
elseif(WIN32)
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
else()
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
    set(STATUS "UNIX Based SYSTEM")
endif()

# ━━━━━━━━━━━━━━━━━━━━━ Installation Related ━━━━━━━━━━━━━━━━━━━━━
set(CMAKE_INSTALL_PREFIX "./packages/com.mainprogram/data")

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
