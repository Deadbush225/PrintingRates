cmake_minimum_required(VERSION 3.16)

if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)
endif()

# Enable improved language standard/extension flag handling
if(POLICY CMP0128)
    cmake_policy(SET CMP0128 NEW)
endif()

# Set policy for install path normalization
if(POLICY CMP0177)
    cmake_policy(SET CMP0177 NEW)
endif()

set(CMAKE_BUILD_TYPE "Release")

# Allow disabling Qt deploy script generation (useful for older distro Qt packages or CI)
option(ENABLE_QT_DEPLOY_SCRIPT "Generate and run Qt deploy script during install" ON)

# Use Windows-specific Boost hint only on developer machines without toolchains; don't pollute CI
if(WIN32 AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(Boost_ROOT D:/Dev/boost_1_87_0/stage)
    list(APPEND CMAKE_PREFIX_PATH ${Boost_ROOT})
elseif(NOT WIN32)
    # Force FindBoost module instead of a BoostConfig.cmake on Linux
    set(Boost_NO_BOOST_CMAKE ON)
endif()

set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/install)

project(PrintingRates VERSION 0.1.0)
set(PROJECT_NAME PrintingRates)
set(PROJECT_SOURCE ${CMAKE_SOURCE_DIR}/src)
message("\nPROJECT SOURCE: " ${PROJECT_SOURCE})

# Global C++ standard settings for all targets
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Common Windows definitions
if(WIN32)
    add_compile_definitions(WIN32_LEAN_AND_MEAN NOMINMAX)
endif()

# Turn on automatic invocation of the MOC, UIC & RCC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Prefer static libs for distribution packages to avoid version conflicts
if(NOT WIN32)
    set(Boost_USE_STATIC_LIBS ON)
endif()

find_package(Qt6 REQUIRED COMPONENTS Widgets Core)
qt_standard_project_setup()

include(GNUInstallDirs)

# Set custom install directories for the new structure
set(CMAKE_INSTALL_BINDIR "bin")
set(CMAKE_INSTALL_LIBDIR "lib")
set(CMAKE_INSTALL_ICONDIR "icons")

message(STATUS "Using toolchain file: ${CMAKE_TOOLCHAIN_FILE}")

# Simple Boost setup - only need log libraries
# Try vcpkg/modern CMake first, then fall back to BOOST_ROOT approach
find_package(Boost QUIET COMPONENTS log log_setup)

if(Boost_FOUND)
    message(STATUS "Found Boost via find_package: ${Boost_VERSION}")
    set(BOOST_AVAILABLE TRUE)
elseif(WIN32 AND DEFINED BOOST_ROOT)
    message(STATUS "Using BOOST_ROOT: ${BOOST_ROOT}")

    # Candidate include directories
    set(_BOOST_INC_DIRS)

    if(EXISTS "${BOOST_ROOT}/include/boost")
        list(APPEND _BOOST_INC_DIRS "${BOOST_ROOT}/include")
    endif()

    if(EXISTS "${BOOST_ROOT}/boost")
        list(APPEND _BOOST_INC_DIRS "${BOOST_ROOT}")
    endif()

    if(NOT _BOOST_INC_DIRS)
        message(WARNING "Could not find Boost headers under ${BOOST_ROOT}")
    else()
        foreach(_inc IN LISTS _BOOST_INC_DIRS)
            include_directories("${_inc}")
            message(STATUS "Boost includes: ${_inc}")
        endforeach()
    endif()

    # Candidate library directories
    foreach(_cand IN ITEMS
        "${BOOST_ROOT}/lib"
        "${BOOST_ROOT}/stage/lib"
        "${BOOST_ROOT}/lib64-msvc-14.3"
        "${BOOST_ROOT}/lib64-msvc-14.2"
    )
        if(EXISTS "${_cand}")
            link_directories("${_cand}")
            message(STATUS "Boost libs: ${_cand}")
        endif()
    endforeach()

    set(BOOST_AVAILABLE TRUE)
else()
    # Use system Boost on Linux (or non-Windows)
    find_package(Boost QUIET COMPONENTS log log_setup)

    if(Boost_FOUND)
        include_directories(${Boost_INCLUDE_DIRS})
        set(BOOST_AVAILABLE TRUE)
        message(STATUS "Using system Boost: ${Boost_VERSION}")
    else()
        # Fallback: try to locate the log headers and library manually
        message(STATUS "find_package(Boost) failed; attempting manual detection...")
        find_path(Boost_INCLUDE_DIRS NAMES boost/log/log.hpp
            PATHS /usr/include /usr/local/include /opt/local/include ${CMAKE_SYSTEM_PREFIX_PATH}
            NO_DEFAULT_PATH)

        if(Boost_INCLUDE_DIRS)
            include_directories(${Boost_INCLUDE_DIRS})
            message(STATUS "Found Boost headers at: ${Boost_INCLUDE_DIRS}")

            # Try to find the log libraries
            find_library(Boost_LOG_LIBRARY
                NAMES boost_log boost_log-mt
                PATHS /usr/lib /usr/local/lib /usr/lib64 /usr/local/lib64
                NO_DEFAULT_PATH)

            find_library(Boost_LOG_SETUP_LIBRARY
                NAMES boost_log_setup boost_log_setup-mt
                PATHS /usr/lib /usr/local/lib /usr/lib64 /usr/local/lib64
                NO_DEFAULT_PATH)

            if(Boost_LOG_LIBRARY AND Boost_LOG_SETUP_LIBRARY)
                message(STATUS "Found Boost log libraries: ${Boost_LOG_LIBRARY}, ${Boost_LOG_SETUP_LIBRARY}")
                set(BOOST_AVAILABLE TRUE)

                # expose variables similar to FindBoost
                set(Boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
                set(Boost_LIBRARIES ${Boost_LOG_LIBRARY} ${Boost_LOG_SETUP_LIBRARY})
            else()
                message(WARNING "Boost headers found but log libraries not found; logging will be disabled")
                set(BOOST_AVAILABLE FALSE)
            endif()
        else()
            set(BOOST_AVAILABLE FALSE)
            message(WARNING "Boost not found - logging features disabled")
            message(STATUS "Searched include paths: /usr/include /usr/local/include /opt/local/include and CMAKE_SYSTEM_PREFIX_PATH")
        endif()
    endif()
endif()

# Expose Boost availability to all targets as a macro
if(BOOST_AVAILABLE)
    add_compile_definitions(HAVE_BOOST_LOG=1)
else()
    add_compile_definitions(HAVE_BOOST_LOG=0)
endif()

include_directories(${PROJECT_SOURCE_DIR}/Include)

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

# binary's icon
set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/src/icons/Printing Rates.rc")

add_executable(${PROJECT_NAME} ${SOURCE_FILES}
    ${app_icon_resource_windows}
    src/icons/resource.qrc)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    message("Removing Console...\n")
    set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE true)
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME})

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Widgets Qt6::Core)

# Propagate Boost availability to the app target too
if(BOOST_AVAILABLE)
    target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_BOOST_LOG=1)

    # Prefer modern CMake targets if available (vcpkg/modern find_package)
    if(TARGET Boost::log AND TARGET Boost::log_setup)
        target_link_libraries(${PROJECT_NAME} PUBLIC Boost::log Boost::log_setup)
        message(STATUS "Using modern Boost CMake targets")
    elseif(WIN32 AND DEFINED BOOST_ROOT)
        target_link_libraries(${PROJECT_NAME} PUBLIC "boost_log" "boost_log_setup")
        message(STATUS "Using BOOST_ROOT library names")
    else()
        target_link_libraries(${PROJECT_NAME} PUBLIC ${Boost_LIBRARIES})
        message(STATUS "Using Boost_LIBRARIES: ${Boost_LIBRARIES}")
    endif()
else()
    target_compile_definitions(${PROJECT_NAME} PRIVATE HAVE_BOOST_LOG=0)
endif()

# Install system eUpdater if available
find_program(EUPDATER_EXECUTABLE NAMES eUpdater eUpdater.exe)

if(EUPDATER_EXECUTABLE)
    get_filename_component(EUPDATER_DIR ${EUPDATER_EXECUTABLE} DIRECTORY)
    install(PROGRAMS ${EUPDATER_EXECUTABLE} DESTINATION ${CMAKE_INSTALL_BINDIR})
    message(STATUS "Found eUpdater: ${EUPDATER_EXECUTABLE}")
else()
    message(WARNING "eUpdater not found in system PATH. Update functionality may not work.")
endif()

# Install main app icon to /icons (for install package and installer)
set(ROOT_ICON_PNG "${CMAKE_CURRENT_SOURCE_DIR}/docs/Printing Rates.png")
set(ROOT_ICON_ICO "${CMAKE_CURRENT_SOURCE_DIR}/src/icons/Printing Rates.ico")

if(EXISTS ${ROOT_ICON_PNG})
    install(FILES ${ROOT_ICON_PNG} DESTINATION ${CMAKE_INSTALL_ICONDIR})
endif()

# Install ICO files for Windows installer and program use
if(EXISTS ${ROOT_ICON_ICO})
    # Install to /icons for Windows installer
    install(FILES ${ROOT_ICON_ICO} DESTINATION ${CMAKE_INSTALL_ICONDIR})

    # Install to /bin/Icons for program use
    install(FILES ${ROOT_ICON_ICO} DESTINATION ${CMAKE_INSTALL_BINDIR}/Icons)
endif()

# Install manifest.json to root
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/manifest.json" DESTINATION .)

# Install install.sh (the generic desktop install script) to root
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/scripts/generic-desktop-install.sh")
    install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/scripts/generic-desktop-install.sh"
        DESTINATION .
        RENAME "install.sh")

    # Make install.sh executable during install
    install(CODE "execute_process(COMMAND chmod +x \"${CMAKE_INSTALL_PREFIX}/install.sh\")")
endif()

# Install the main application executable so install_local populates ./install
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})

# Generate and run Qt deploy script (guarded for older Qt and can be disabled)
if(ENABLE_QT_DEPLOY_SCRIPT)
    if(APPLE)
        if(COMMAND qt_generate_deploy_app_script)
            # Only run the Qt deploy script generator on macOS (the helper's
            # signature has varied between Qt versions and some platforms don't
            # provide it). This avoids the "Unexpected arguments" error on other
            # platforms.
            qt_generate_deploy_app_script(
                TARGET ${PROJECT_NAME} OUTPUT_SCRIPT deploy_script
            ) # create deploy script
            install(SCRIPT ${deploy_script}) # run deploy script
        else()
            message(STATUS "qt_generate_deploy_app_script not available on this Qt build; skipping deploy script generation on macOS")
        endif()
    elseif(WIN32)
        # On Windows, prefer to run windeployqt (if available) after install.
        find_program(WINDEPLOYQT_EXECUTABLE
            NAMES windeployqt.exe windeployqt
            HINTS $ENV{Qt6_DIR} PATH_SUFFIXES bin
        )

        if(WINDEPLOYQT_EXECUTABLE)
            message(STATUS "windeployqt found: ${WINDEPLOYQT_EXECUTABLE}; adding install-time invocation")

            # Run windeployqt as part of the install step so the ./install tree
            # gets populated with Qt runtime artifacts. Use install(CODE ...) so
            # it runs at install time.
            install(CODE "execute_process(COMMAND \"${WINDEPLOYQT_EXECUTABLE}\" --release --dir \"${CMAKE_INSTALL_PREFIX}\" \"${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${PROJECT_NAME}.exe\"\n)")
        else()
            message(STATUS "windeployqt not found; skipping automatic windeployqt invocation on Windows")
        endif()
    else()
        # Linux and other platforms: do not call the Qt deploy script here. On
        # Linux we package via separate scripts (deb/rpm/AppImage) and calling
        # the Qt deployment generator may be unsupported or unnecessary.
        message(STATUS "Skipping qt_generate_deploy_app_script on this platform (not macOS)")
    endif()
else()
    message(STATUS "ENABLE_QT_DEPLOY_SCRIPT=OFF; skipping Qt deploy script generation")
endif()

# Prune optional/banned bits that may remain or from previous installs using a script file
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PruneInstall.cmake")
    install(SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PruneInstall.cmake")
endif()

# --- Convenience install targets -------------------------------------------
# install_local: Build app + eUpdater, then remove
# ./install and perform an installation into ./install using cmake --install.
set(INSTALL_LOCAL_DIR "${CMAKE_SOURCE_DIR}/install")

add_custom_target(install_local
    COMMAND ${CMAKE_COMMAND} -E echo "Cleaning ${INSTALL_LOCAL_DIR}"
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${INSTALL_LOCAL_DIR}"
    COMMAND ${CMAKE_COMMAND} -E make_directory "${INSTALL_LOCAL_DIR}"
    COMMAND ${CMAKE_COMMAND} -E echo "Installing to ${INSTALL_LOCAL_DIR}"
    COMMAND ${CMAKE_COMMAND} --install "${CMAKE_BINARY_DIR}" --config $<IF:$<BOOL:$<CONFIG>>,$<CONFIG>,Release> --prefix "${INSTALL_LOCAL_DIR}"
    DEPENDS ${PROJECT_NAME}
    USES_TERMINAL
    COMMENT "Build + local install to ${INSTALL_LOCAL_DIR}"
)

add_dependencies(install_local ${PROJECT_NAME})
