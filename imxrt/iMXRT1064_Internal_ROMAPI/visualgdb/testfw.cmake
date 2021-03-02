#This is typically called by the test framework definition that is loaded by find_test_framework() 
function(create_test_framework_library_from_vars framework_id)
	set(name ${TESTFW_ALIAS})
	create_bsp_library(${name} ${_sources})
	
	target_include_directories(${name} PUBLIC ${_includes})
	target_compile_definitions(${name} PUBLIC ${_defines})
	target_compile_options(${name} PUBLIC ${_cflags})
	target_link_libraries(${name} PUBLIC ${_ldflags} ${TESTFW_BSP_ALIAS})

	set(${name}_FRAMEWORK_ID ${framework_id} CACHE INTERNAL "")

endfunction()

function(find_test_framework)
    set(options)
    set(oneValueArgs ID ALIAS BSP_ALIAS EXPLICIT_LOCATION)
    set(multiValueArgs CONFIGURATION)

    cmake_parse_arguments(TESTFW "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if("${TESTFW_ALIAS}" STREQUAL "")
        set(TESTFW_ALIAS TESTFW)
    endif()

    if("${TESTFW_BSP_ALIAS}" STREQUAL "")
        set(TESTFW_BSP_ALIAS BSP)
    endif()

	set(${TESTFW_ALIAS}_TEST_FRAMEWORK_ID ${TESTFW_ID} CACHE INTERNAL "")

    foreach(kv ${TESTFW_CONFIGURATION})
		string(REGEX REPLACE "^[ ]+" "" kv ${kv})
		string(REGEX MATCH "^[^=]+" Key ${kv})
		string(REPLACE "${Key}=" "" Value ${kv})
		set(BSP_CONFIGURATION_${Key} "${Value}")

	    set(${TESTFW_ALIAS}_CFG_${Key} ${Value} CACHE INTERNAL "")

    endforeach()

	if("${TESTFW_EXPLICIT_LOCATION}" STREQUAL "")
	    #This is defined in FindFrameworks.cmake that is updated by VisualGDB based on the installed frameworks
		visualgdb_instantiate_test_framework(${TESTFW_ID})
	else()
		if (NOT(IS_ABSOLUTE ${TESTFW_EXPLICIT_LOCATION}))
			set(TESTFW_EXPLICIT_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/${TESTFW_EXPLICIT_LOCATION})
		endif()

		if(NOT EXISTS "${TESTFW_EXPLICIT_LOCATION}/framework.cmake")
			message(FATAL_ERROR "Test framework directory does not contain framework.cmake")
		endif()

		include("${TESTFW_EXPLICIT_LOCATION}/framework.cmake")
	endif()
	
endfunction()