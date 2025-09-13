# Runs at install time to remove optional/banned files from the install tree

# Common helper to safely remove matching files
function(_rm_glob)
    file(GLOB _tmp ${ARGV})

    if(_tmp)
        foreach(_file IN LISTS _tmp)
            message(STATUS "Removing: ${_file}")
            file(REMOVE "${_file}")
        endforeach()
    endif()
endfunction()

# Remove software OpenGL and graphics acceleration DLLs
_rm_glob("${CMAKE_INSTALL_PREFIX}/opengl32sw.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/opengl32sw.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6OpenGL*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6OpenGL*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6OpenGLWidgets*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6OpenGLWidgets*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6ANGLE*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6ANGLE*.dll")

# Remove debug builds
_rm_glob("${CMAKE_INSTALL_PREFIX}/*d.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/*d.dll")

# Remove unused Qt modules
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Network.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Network.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Concurrent.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Concurrent.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6PrintSupport.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6PrintSupport.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Multimedia*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Multimedia*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Quick*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Quick*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Qml*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Qml*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Test.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Test.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Sql.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Sql.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Xml.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Xml.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6SerialPort.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6SerialPort.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6WebEngine*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6WebEngine*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Positioning.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Positioning.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6Sensors.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6Sensors.dll")

# Remove ICU and DBus if present (not needed for basic widgets apps on MSVC)
_rm_glob("${CMAKE_INSTALL_PREFIX}/icudt*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/icudt*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/icuin*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/icuin*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/icuuc*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/icuuc*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/Qt6DBus*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/Qt6DBus*.dll")

# Remove MSVC runtime DLLs (should be installed system-wide)
_rm_glob("${CMAKE_INSTALL_PREFIX}/concrt140.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/concrt140.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/msvcp140*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/msvcp140*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/vcruntime140*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/vcruntime140*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/api-ms-*.dll")
_rm_glob("${CMAKE_INSTALL_PREFIX}/bin/api-ms-*.dll")

# Remove plugin folders we don't want
file(REMOVE_RECURSE
    "${CMAKE_INSTALL_PREFIX}/tls"
    "${CMAKE_INSTALL_PREFIX}/bin/tls"
    "${CMAKE_INSTALL_PREFIX}/networkinformation"
    "${CMAKE_INSTALL_PREFIX}/bin/networkinformation"
    "${CMAKE_INSTALL_PREFIX}/bearer"
    "${CMAKE_INSTALL_PREFIX}/bin/bearer"
    "${CMAKE_INSTALL_PREFIX}/sqldrivers"
    "${CMAKE_INSTALL_PREFIX}/bin/sqldrivers"
    "${CMAKE_INSTALL_PREFIX}/multimedia"
    "${CMAKE_INSTALL_PREFIX}/bin/multimedia"
    "${CMAKE_INSTALL_PREFIX}/qmltooling"
    "${CMAKE_INSTALL_PREFIX}/bin/qmltooling"
    "${CMAKE_INSTALL_PREFIX}/quick"
    "${CMAKE_INSTALL_PREFIX}/bin/quick"
    "${CMAKE_INSTALL_PREFIX}/scenegraph"
    "${CMAKE_INSTALL_PREFIX}/bin/scenegraph"
    "${CMAKE_INSTALL_PREFIX}/translations"
    "${CMAKE_INSTALL_PREFIX}/bin/translations"
    "${CMAKE_INSTALL_PREFIX}/generic"
    "${CMAKE_INSTALL_PREFIX}/bin/generic"
)

# Remove image format plugins we don't use (keep png and ico)
file(GLOB _img_unneeded
    "${CMAKE_INSTALL_PREFIX}/imageformats/qgif*.dll"
    "${CMAKE_INSTALL_PREFIX}/imageformats/qjpeg*.dll"
    "${CMAKE_INSTALL_PREFIX}/imageformats/qsvg*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/imageformats/qgif*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/imageformats/qjpeg*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/imageformats/qsvg*.dll"
)

if(_img_unneeded)
    foreach(_file IN LISTS _img_unneeded)
        message(STATUS "Removing image plugin: ${_file}")
        file(REMOVE "${_file}")
    endforeach()
endif()

# Remove OpenSSL if it slipped in
_rm_glob(
    "${CMAKE_INSTALL_PREFIX}/libssl*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libssl*.dll"
    "${CMAKE_INSTALL_PREFIX}/libcrypto*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libcrypto*.dll"
)

# Remove D3DCompiler (ANGLE) and DirectX components if copied
_rm_glob(
    "${CMAKE_INSTALL_PREFIX}/d3dcompiler*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/d3dcompiler*.dll"
    "${CMAKE_INSTALL_PREFIX}/D3DCompiler*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/D3DCompiler*.dll"
    "${CMAKE_INSTALL_PREFIX}/dxcompiler*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/dxcompiler*.dll"
    "${CMAKE_INSTALL_PREFIX}/dxil*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/dxil*.dll"
)

# Remove MinGW runtime DLLs (not applicable on MSVC, but safe if present)
_rm_glob(
    "${CMAKE_INSTALL_PREFIX}/libgcc_s_seh-1.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libgcc_s_seh-1.dll"
    "${CMAKE_INSTALL_PREFIX}/libstdc++-6.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libstdc++-6.dll"
    "${CMAKE_INSTALL_PREFIX}/libwinpthread-1.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libwinpthread-1.dll"
)

# Remove unused Boost DLLs (keep only log and log_setup that this project uses)
# Note: Static linking is preferred, but if dynamic linking is used, keep only needed libs
file(GLOB _boost_unneeded
    "${CMAKE_INSTALL_PREFIX}/boost_chrono*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_date_time*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_filesystem*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_graph*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_iostreams*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_locale*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_math*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_program_options*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_random*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_regex*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_serialization*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_system*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_test*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_thread*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_timer*.dll"
    "${CMAKE_INSTALL_PREFIX}/boost_wave*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_chrono*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_date_time*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_filesystem*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_graph*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_iostreams*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_locale*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_math*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_program_options*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_random*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_regex*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_serialization*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_system*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_test*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_thread*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_timer*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/boost_wave*.dll"

    # Also remove libboost variants (keep log libs)
    "${CMAKE_INSTALL_PREFIX}/libboost_chrono*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_date_time*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_filesystem*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_graph*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_iostreams*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_locale*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_math*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_program_options*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_random*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_regex*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_serialization*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_system*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_test*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_thread*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_timer*.dll"
    "${CMAKE_INSTALL_PREFIX}/libboost_wave*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_chrono*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_date_time*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_filesystem*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_graph*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_iostreams*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_locale*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_math*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_program_options*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_random*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_regex*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_serialization*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_system*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_test*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_thread*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_timer*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/libboost_wave*.dll"
)

if(_boost_unneeded)
    foreach(_file IN LISTS _boost_unneeded)
        message(STATUS "Removing unused Boost library: ${_file}")
        file(REMOVE "${_file}")
    endforeach()
endif()

message(STATUS "PruneInstall.cmake completed")
