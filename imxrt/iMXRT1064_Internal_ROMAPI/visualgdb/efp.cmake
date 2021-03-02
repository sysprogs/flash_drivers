#This function expects ${BSP_ALIAS} to be set correctly
function(create_bsp_framework_library_from_vars framework_type framework_id short_name user_friendly_name)
	set(name ${BSP_ALIAS}_${short_name})
	
	if("${framework_type}" STREQUAL "StandaloneEFP")
		set(name ${_standalone_framework_name})
	endif()

	set(${name}_FRAMEWORK_ID ${framework_id} CACHE INTERNAL "")
	set(${name}_FRAMEWORK_TYPE ${framework_type} CACHE INTERNAL "")
	set(${name}_FRAMEWORK_CAPTION ${user_friendly_name} CACHE INTERNAL "")

	create_bsp_library(${name} ${_sources})
	set(_created_library ${name} PARENT_SCOPE)
	
	if("${framework_type}" STREQUAL "StandaloneEFP")
		target_compile_definitions(${name} PUBLIC ${_defines})
		target_include_directories(${name} PUBLIC ${_includes})
	else()

		#Due to backward compatibility with MSBuild, BSP frameworks add their includes/defines to ALL components dependent on that BSP.
		set(_core_includes ${_core_includes} ${_includes} PARENT_SCOPE)

		if("${CMAKE_BUILD_TYPE}" STREQUAL "DEBUG")
			set(_core_defines ${_core_defines} ${_defines} DEBUG=1 PARENT_SCOPE)
		else()
			set(_core_defines ${_core_defines} ${_defines} PARENT_SCOPE)
		endif()

		set(_core_forced_includes ${_core_forced_includes} ${_forced_includes} PARENT_SCOPE)
	endif()

	target_link_libraries(${name} PRIVATE ${BSP_ALIAS})	#This pulls BSP-level includes and defines
	
	add_coverage_flags_and_targets(${BSP_ALIAS} ${name})	#This propagates the pre-link command
endfunction()

function(import_framework)
    cmake_parse_arguments(_fw "" "NAME;PATH;BSP_ALIAS" "CONFIGURATION;REFERENCES" ${ARGN})

	get_filename_component(_fw_path_ABSOLUTE ${_fw_PATH} REALPATH)

	if (NOT EXISTS "${_fw_PATH}/framework.cmake")
		exec_program($ENV{VISUALGDB_DIR}/VisualGDB.exe $ENV{VISUALGDB_DIR} ARGS "/cmake ${_fw_path_ABSOLUTE}")
	endif()

    foreach(kv ${_fw_CONFIGURATION})
		string(REGEX REPLACE "^[ ]+" "" kv ${kv})
		string(REGEX MATCH "^[^=]+" Key ${kv})
		string(REPLACE "${Key}=" "" Value ${kv})
		set(BSP_CONFIGURATION_${Key} "${Value}")
    endforeach()

	set(BSP_ALIAS ${_fw_BSP_ALIAS})

	if("${BSP_ALIAS}" STREQUAL "")
		set(BSP_ALIAS BSP)
	endif()
	
	foreach(_var ${_${BSP_ALIAS}_VARIABLES})
		set(${_var} ${_${BSP_ALIAS}_${_var}})
	endforeach()

	set(FRAMEWORK_ROOT ${_fw_PATH})
	set(_standalone_framework_name ${_fw_NAME})
	include(${_fw_PATH}/framework.cmake)

	target_link_libraries(${_fw_NAME} PRIVATE ${_fw_REFERENCES})	

	set(${_fw_NAME}_FRAMEWORK_LOCATION ${_fw_path_ABSOLUTE} CACHE INTERNAL "")

endfunction()