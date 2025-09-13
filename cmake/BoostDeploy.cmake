# CMake utility to selectively deploy only needed Boost DLLs
# Usage: include this file and call deploy_boost_dlls(component1 component2 ...)

# Function to deploy only specified Boost DLLs to the install directory
function(deploy_boost_dlls)
    set(_needed_components ${ARGV})

    if(NOT _needed_components)
        message(STATUS "No Boost components specified - skipping Boost DLL deployment")
        return()
    endif()

    message(STATUS "Deploying Boost DLLs for components: ${_needed_components}")

    # Only deploy on Windows with dynamic Boost linking
    if(NOT WIN32)
        message(STATUS "Boost DLL deployment only needed on Windows")
        return()
    endif()

    # Check if we're using dynamic Boost libraries
    if(Boost_USE_STATIC_LIBS)
        message(STATUS "Using static Boost linking - no DLL deployment needed")
        return()
    endif()

    # Find Boost DLLs that need to be deployed
    set(_boost_dlls_to_deploy)

    foreach(_component IN LISTS _needed_components)
        # Look for Boost DLLs in common locations
        set(_boost_search_paths)

        # Add Boost library paths if available
        if(Boost_LIBRARY_DIRS)
            list(APPEND _boost_search_paths ${Boost_LIBRARY_DIRS})
        endif()

        # Add BOOST_ROOT paths if available
        if(BOOST_ROOT)
            list(APPEND _boost_search_paths
                "${BOOST_ROOT}/lib"
                "${BOOST_ROOT}/stage/lib"
                "${BOOST_ROOT}/bin"
            )
        endif()

        # Add system paths
        list(APPEND _boost_search_paths
            "C:/local/boost*/lib*"
            "C:/tools/boost*/lib*"
            "C:/vcpkg/installed/*/bin"
            "C:/vcpkg/installed/*/lib"
        )

        # Search for the component DLL
        set(_component_dll_found FALSE)

        foreach(_search_path IN LISTS _boost_search_paths)
            file(GLOB _candidate_dlls
                "${_search_path}/*boost*${_component}*.dll"
                "${_search_path}/boost_${_component}*.dll"
                "${_search_path}/libboost_${_component}*.dll"
            )

            if(_candidate_dlls)
                foreach(_dll IN LISTS _candidate_dlls)
                    # Exclude debug versions in release builds
                    get_filename_component(_dll_name "${_dll}" NAME)

                    if(CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "")
                        if(NOT _dll_name MATCHES ".*d\\.dll$")
                            list(APPEND _boost_dlls_to_deploy "${_dll}")
                            set(_component_dll_found TRUE)
                            message(STATUS "Found Boost DLL for ${_component}: ${_dll}")
                        endif()
                    else()
                        # For debug builds, prefer debug DLLs but accept release if needed
                        list(APPEND _boost_dlls_to_deploy "${_dll}")
                        set(_component_dll_found TRUE)
                        message(STATUS "Found Boost DLL for ${_component}: ${_dll}")
                    endif()
                endforeach()
            endif()

            if(_component_dll_found)
                break()
            endif()
        endforeach()

        if(NOT _component_dll_found)
            message(WARNING "Could not find Boost DLL for component: ${_component}")
        endif()
    endforeach()

    # Install the found Boost DLLs
    if(_boost_dlls_to_deploy)
        list(REMOVE_DUPLICATES _boost_dlls_to_deploy)

        foreach(_dll IN LISTS _boost_dlls_to_deploy)
            install(FILES "${_dll}" DESTINATION ${CMAKE_INSTALL_BINDIR})
            message(STATUS "Will install Boost DLL: ${_dll}")
        endforeach()
    else()
        message(STATUS "No Boost DLLs found for deployment - likely using static linking")
    endif()
endfunction()

# Convenience function for common Boost components
function(deploy_boost_program_options)
    deploy_boost_dlls("program_options")
endfunction()

function(deploy_boost_log)
    deploy_boost_dlls("log" "log_setup")
endfunction()

function(deploy_boost_filesystem)
    deploy_boost_dlls("filesystem" "system")
endfunction()

function(deploy_boost_thread)
    deploy_boost_dlls("thread" "system")
endfunction()

message(STATUS "Boost deployment utilities loaded")
