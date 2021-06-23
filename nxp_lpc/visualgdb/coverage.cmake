function(add_coverage_flags_and_targets bsp_alias target_name)
    get_target_property(_enable_code_coverage ${bsp_alias} ENABLE_CODE_COVERAGE)

    if(${_enable_code_coverage})
        get_target_property(_excluded_targets ${bsp_alias} TARGETS_EXCLUDED_FROM_COVERAGE)
        if(NOT(${target_name} IN_LIST _excluded_targets))

            get_target_property(_target_type ${target_name} TYPE)
            if (NOT (${_target_type} STREQUAL "OBJECT_LIBRARY"))
                set(_effective_sources $<TARGET_OBJECTS:${target_name}>)

                get_target_property(_linked_libraries ${target_name} LINK_LIBRARIES)
                foreach(_reflib ${_linked_libraries})
                    if (TARGET ${_reflib})
                        get_target_property(_reflib_target_type ${_reflib} TYPE)
                        if (${_reflib_target_type} STREQUAL "OBJECT_LIBRARY")
                            set(_effective_sources ${_effective_sources} $<TARGET_OBJECTS:${_reflib}>)
                        endif()
                    endif()
                endforeach()

                add_custom_command(TARGET ${target_name} PRE_LINK COMMAND "$ENV{VISUALGDB_DIR}/VisualGDB.exe" ARGS /decover $<TARGET_FILE:${target_name}> ${_effective_sources})
            endif()

            get_target_property(_excluded_files ${bsp_alias} FILES_EXCLUDED_FROM_COVERAGE)

            if(NOT("${_excluded_files}" STREQUAL ""))
                get_target_property(_sources ${target_name} SOURCES)
                foreach(_source ${_sources})
                    get_filename_component(_fullpath ${_source} REALPATH)

                    if(NOT (${_fullpath} IN_LIST _excluded_files))
                        set_source_files_properties(${_source} PROPERTIES COMPILE_FLAGS -coverage)
                    endif()
                endforeach()
            else()
    		    target_compile_options(${target_name} PRIVATE -coverage)
            endif()
        endif()

    endif()
endfunction()

function(bsp_configure_code_coverage)
    cmake_parse_arguments(BSP "" "ENABLED;ALIAS" "EXCLUDE_FILES;EXCLUDE_TARGETS" ${ARGN})
	
	if(${BSP_ENABLED})
		if("${BSP_ALIAS}" STREQUAL "")
			set(BSP_ALIAS BSP)
		endif()

		set(_excluded_files)
		foreach(_file ${BSP_EXCLUDE_FILES})
			get_filename_component(_fullpath ${_file} REALPATH)
			set(_excluded_files ${_excluded_files} ${_fullpath})
		endforeach()
		
		set_property(TARGET ${BSP_ALIAS} PROPERTY ENABLE_CODE_COVERAGE TRUE)
		set_property(TARGET ${BSP_ALIAS} PROPERTY FILES_EXCLUDED_FROM_COVERAGE ${_excluded_files})
		set_property(TARGET ${BSP_ALIAS} PROPERTY TARGETS_EXCLUDED_FROM_COVERAGE ${BSP_EXCLUDE_TARGETS})

        set(_${BSP_ALIAS}_FILES_EXCLUDED_FROM_COVERAGE ${_excluded_files} CACHE INTERNAL "")
        set(_${BSP_ALIAS}_TARGETS_EXCLUDED_FROM_COVERAGE ${BSP_EXCLUDE_TARGETS} CACHE INTERNAL "")
		
		foreach(_target ${${BSP_ALIAS}_ASSOCIATED_TARGETS})
			add_coverage_flags_and_targets(${BSP_ALIAS} ${_target})	#This creates the /decover command for the BSP itself if the code coverage is enabled
		endforeach()
	endif()

    set(_${BSP_ALIAS}_COVERAGE_ENABLED ${BSP_ENABLED} CACHE INTERNAL "")

endfunction()