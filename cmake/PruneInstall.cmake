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

# Deploy only needed Boost DLLs (this project uses: log, log_setup)
# This approach selectively keeps only what's needed instead of removing everything else
set(_NEEDED_BOOST_LIBS "log;log_setup")

# Function to selectively install only needed Boost libraries
function(install_needed_boost_libs needed_libs)
    message(STATUS "Installing only needed Boost libraries: ${needed_libs}")

    # First, find all Boost DLLs that were deployed
    file(GLOB_RECURSE _all_boost_dlls
        "${CMAKE_INSTALL_PREFIX}/*boost*.dll"
        "${CMAKE_INSTALL_PREFIX}/bin/*boost*.dll"
    )

    # Create list of DLLs to keep
    set(_dlls_to_keep)

    foreach(_needed_lib IN LISTS needed_libs)
        foreach(_dll IN LISTS _all_boost_dlls)
            get_filename_component(_dll_name "${_dll}" NAME_WE)

            # Match boost_log, libboost_log, boost_log_setup, etc.
            if(_dll_name MATCHES ".*boost.*${_needed_lib}.*")
                list(APPEND _dlls_to_keep "${_dll}")
                message(STATUS "Keeping needed Boost DLL: ${_dll}")
            endif()
        endforeach()
    endforeach()

    # Remove all other Boost DLLs
    foreach(_dll IN LISTS _all_boost_dlls)
        list(FIND _dlls_to_keep "${_dll}" _keep_index)

        if(_keep_index EQUAL -1)
            message(STATUS "Removing unneeded Boost DLL: ${_dll}")
            file(REMOVE "${_dll}")
        endif()
    endforeach()
endfunction()

# Only install needed Boost libraries if any Boost DLLs are present
file(GLOB _boost_check
    "${CMAKE_INSTALL_PREFIX}/*boost*.dll"
    "${CMAKE_INSTALL_PREFIX}/bin/*boost*.dll"
)

if(_boost_check)
    install_needed_boost_libs("${_NEEDED_BOOST_LIBS}")
else()
    message(STATUS "No Boost DLLs found - likely using static linking (preferred)")
endif()

message(STATUS "PruneInstall.cmake completed")
