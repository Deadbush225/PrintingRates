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

set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/src/icons/Printing Rates.rc")
add_executable(${PROJECT_NAME} ${SOURCE_FILES} ${app_icon_resource_windows} src/icons/resource.qrc)
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "Printing Rates")

if(CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE true)
endif()

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

message(Boost_LIBRARIES: ${Boost_LIBRARIES}) # no contents
message(Boost_INCLUDE_DIRS: ${Boost_INCLUDE_DIRS}) # no contents

target_include_directories(${PROJECT_NAME} PRIVATE ${Boost_INCLUDE_DIRS})

# target_link_libraries(${PROJECT_NAME} PUBLIC ${Boost_LIBRARIES})
target_link_libraries(${PROJECT_NAME} PUBLIC Boost::log Boost::log_setup)

if(APPLE)
    set(executable_path "$<TARGET_FILE_NAME:${PROJECT_NAME}>.app")
elseif(WIN32)
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
else()
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
    set(STATUS "UNIX Based SYSTEM")
endif()

# ━━━━━━━━━━━━━━━━━━━━━ Installation Related ━━━━━━━━━━━━━━━━━━━━━
set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install")

set(deploy_script "${CMAKE_CURRENT_BINARY_DIR}/deploy_${PROJECT_NAME}.cmake")

file(GENERATE OUTPUT ${deploy_script} CONTENT "
include(\"${QT_DEPLOY_SUPPORT}\")
qt_deploy_runtime_dependencies(
    EXECUTABLE \"${executable_path}\"
    PLUGINS_DIR bin
)")

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
install(SCRIPT ${deploy_script})
