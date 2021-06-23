include(${CMAKE_CURRENT_LIST_DIR}/bsp.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/testfw.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/efp.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/resources.cmake)

if ("${VISUALGDB_TOOLCHAIN_TYPE}" STREQUAL "Windows")
    set(SIMULATION 1)
else()
    set(SIMULATION 0)
endif()

if("${VISUALGDB_TOOLCHAIN_SUBTYPE}" STREQUAL "GCC")
    set(CMAKE_C_FLAGS_DEBUG "-g3 -O0")
    set(CMAKE_CXX_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})

    set(CMAKE_C_FLAGS_RELEASE "-g3 -O3")
    set(CMAKE_CXX_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
endif()

if(EXISTS "${VISUALGDB_COMPONENT_LISTS_DIR}/FindFrameworks.cmake")
	include("${VISUALGDB_COMPONENT_LISTS_DIR}/FindFrameworks.cmake")
endif()

function(apply_linker_script exe script)
	if("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC")
        target_link_libraries(${exe} PRIVATE "--scatter \"${script}\"")
	elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
        target_link_libraries(${exe} PRIVATE "--config \"${script}\"")
    else()
        target_link_libraries(${exe} PRIVATE  "-\"T${script}\"")
    endif()

    set_target_properties(${exe} PROPERTIES LINK_DEPENDS ${script})
endfunction()

function(add_bsp_based_executable)
    set(options GENERATE_BIN GENERATE_HEX PREPROCESS_LINKER_SCRIPT GENERATE_MAP BUILD_UNIT_TESTS OUTPUT_RELOCATION_RECORDS)
    set(oneValueArgs LINKER_SCRIPT BSP_ALIAS NAME TESTFW_ALIAS MEMORY_LIST_FILE ENTRY_POINT)
    set(multiValueArgs SOURCES EXCLUDED_PLATFORMS)

    if("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
	    message(FATAL_ERROR "Embedded CMake projects must explicitly specify the toolchain")
    endif()
	
    cmake_parse_arguments(_exe "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	
    if("${_exe_BSP_ALIAS}" STREQUAL "")
        set(_exe_BSP_ALIAS BSP)
    endif()

    set(_extra_sources)

    set(${_exe_NAME}_EXPLICIT_LINKER_SCRIPT "${_exe_LINKER_SCRIPT}" CACHE INTERNAL "")

    if("${_exe_LINKER_SCRIPT}" STREQUAL "")
        get_target_property(_exe_LINKER_SCRIPT ${_exe_BSP_ALIAS} BSP_LINKER_SCRIPT)
    else()
        get_filename_component(_exe_LINKER_SCRIPT ${_exe_LINKER_SCRIPT} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
        set(_extra_sources ${_extra_sources} ${_exe_LINKER_SCRIPT})
    endif()

    if(NOT ("${_exe_MEMORY_LIST_FILE}" STREQUAL ""))
        set(_extra_sources ${_extra_sources} "${_exe_MEMORY_LIST_FILE}.c" "${_exe_MEMORY_LIST_FILE}.h")
    endif()
	
	ensure_at_least_one_source_exists(_exe_SOURCES)

    if("${PLATFORM}" IN_LIST _exe_EXCLUDED_PLATFORMS)
	    set(${_exe_NAME}_IS_DUMMY 1 CACHE INTERNAL "")
    else()
	    set(${_exe_NAME}_IS_DUMMY 0 CACHE INTERNAL "")
	    add_executable(${_exe_NAME} ${_exe_SOURCES} ${_extra_sources})

	    target_link_libraries(${_exe_NAME} PRIVATE  ${${_exe_BSP_ALIAS}_LIBRARIES})

        if(NOT ${SIMULATION})
            if(${_exe_GENERATE_BIN})
		        if(("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang"))
                    add_custom_command(OUTPUT ${_exe_NAME}.bin COMMAND ${CMAKE_FROMELF} ARGS --bin $<TARGET_FILE:${_exe_NAME}> --output ${_exe_NAME}.bin DEPENDS ${_exe_NAME} COMMENT "Producing ${_exe_NAME}.bin")
		        elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
                    add_custom_command(OUTPUT ${_exe_NAME}.bin COMMAND ${CMAKE_IELFTOOL} ARGS --silent --bin $<TARGET_FILE:${_exe_NAME}> ${_exe_NAME}.bin DEPENDS ${_exe_NAME} COMMENT "Producing ${_exe_NAME}.bin")
                else()
                    add_custom_command(OUTPUT ${_exe_NAME}.bin COMMAND ${CMAKE_OBJCOPY} ARGS -O binary ${_exe_NAME} ${_exe_NAME}.bin DEPENDS ${_exe_NAME} COMMENT "Producing ${_exe_NAME}.bin")
                endif()
                
	            get_filename_component(_bin_path ${CMAKE_CURRENT_BINARY_DIR}/${_exe_NAME}.bin REALPATH)
		        set_property(TARGET ${_exe_NAME} PROPERTY GENERATED_BINARY_FILE ${_bin_path})

                add_custom_target(${_exe_NAME}-bin ALL DEPENDS ${_exe_NAME}.bin)
            endif()

            if(${_exe_GENERATE_HEX})
		        if(("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang"))
                    add_custom_target(${_exe_NAME}.hex ALL ${CMAKE_FROMELF} --i32 $<TARGET_FILE:${_exe_NAME}> --output ${_exe_NAME}.hex DEPENDS ${_exe_NAME} "Producing ${_exe_NAME}.hex")
		        elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
                    add_custom_target(${_exe_NAME}.hex ALL ${CMAKE_IELFTOOL} --silent --i32 $<TARGET_FILE:${_exe_NAME}> ${_exe_NAME}.hex DEPENDS ${_exe_NAME} "Producing ${_exe_NAME}.hex")
                else()
                    add_custom_target(${_exe_NAME}.hex ALL ${CMAKE_OBJCOPY} -O ihex ${_exe_NAME} ${_exe_NAME}.hex DEPENDS ${_exe_NAME} COMMENT "Producing ${_exe_NAME}.hex")
                endif()
            endif()

            if(NOT("${_exe_LINKER_SCRIPT}" STREQUAL ""))
                if (${_exe_PREPROCESS_LINKER_SCRIPT})
                    get_property(_exe_defines TARGET ${_exe_NAME} PROPERTY COMPILE_DEFINITIONS)
                    get_property(_bsp_defines TARGET ${_exe_BSP_ALIAS} PROPERTY COMPILE_DEFINITIONS)
                    list(TRANSFORM _exe_defines PREPEND "-D")
                    list(TRANSFORM _bsp_defines PREPEND "-D")

                    add_custom_target(${_exe_NAME}.lds ALL ${CMAKE_CXX_COMPILER} -x c ${_exe_LINKER_SCRIPT} ${_exe_defines} ${_bsp_defines} -E -P -o ${_exe_NAME}.lds DEPENDS ${_exe_LINKER_SCRIPT})

    		        apply_linker_script(${_exe_NAME} "{_exe_NAME}.lds")
                else()
    		        apply_linker_script(${_exe_NAME} "${_exe_LINKER_SCRIPT}")
                endif()

                set(${_exe_NAME}_LINKER_SCRIPT "${_exe_LINKER_SCRIPT}" CACHE INTERNAL "")
	        elseif(("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang"))
                get_target_property(_base_flags ${_exe_BSP_ALIAS} KEIL_BASE_FLAGS)
                target_link_libraries(${_exe_NAME} PRIVATE ${_base_flags})

                get_target_property(_first_symbol ${_exe_BSP_ALIAS} DEFAULT_FIRST_SYMBOL)
                if(NOT("${_first_symbol}" STREQUAL ""))
                    target_link_libraries(${_exe_NAME} PRIVATE  "--first ${_first_symbol}")
                endif()
            endif()

            if(${_exe_GENERATE_MAP})
		        if(("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang"))
        	        target_link_libraries(${_exe_NAME} PRIVATE  "--map --list ${_exe_NAME}.map")
		        elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
        	        target_link_libraries(${_exe_NAME} PRIVATE  "--map ${_exe_NAME}.map")
                else()
        	        target_link_libraries(${_exe_NAME} PRIVATE  "-Wl,-Map=${_exe_NAME}.map")
                endif()
            endif()

            if("${_exe_ENTRY_POINT}" STREQUAL "")
                get_target_property(_exe_ENTRY_POINT ${_exe_BSP_ALIAS} DEFAULT_ENTRY_POINT)
            endif()

            if(("${_exe_ENTRY_POINT}" STREQUAL "") AND ("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR"))
                set(_exe_ENTRY_POINT __iar_program_start)
            endif()

            if(NOT("${_exe_ENTRY_POINT}" STREQUAL ""))
                target_link_libraries(${_exe_NAME} PRIVATE  "--entry ${_exe_ENTRY_POINT}")
            endif()


            if(${_exe_OUTPUT_RELOCATION_RECORDS})
    	        target_link_libraries(${_exe_NAME} PRIVATE  -Wl,-q)
            endif()
        endif() #SIMULATION

        if(${_exe_BUILD_UNIT_TESTS})
            if("${_exe_TESTFW_ALIAS}" STREQUAL "")
                set(_exe_TESTFW_ALIAS TESTFW)
            endif()
        
    	    target_link_libraries(${_exe_NAME} PRIVATE  ${_exe_TESTFW_ALIAS})
	        set(${_exe_NAME}_TEST_FRAMEWORK_TARGET ${_exe_TESTFW_ALIAS} CACHE INTERNAL "")
        endif()

        copy_property_if_not_defined(${_exe_BSP_ALIAS} ${_exe_NAME} C_STANDARD)
        copy_property_if_not_defined(${_exe_BSP_ALIAS} ${_exe_NAME} CXX_STANDARD)

	    set(${_exe_BSP_ALIAS}_ASSOCIATED_TARGETS ${${_exe_BSP_ALIAS}_ASSOCIATED_TARGETS} ${_exe_NAME} PARENT_SCOPE)
        add_coverage_flags_and_targets(${_exe_BSP_ALIAS} ${_exe_NAME})
    endif() #EXCLUDED_PLATFORMS check
	
	set(${_exe_NAME}_BSP_ALIAS ${_exe_BSP_ALIAS} CACHE STRING "Specifies the BSP alias for the ${name} target." FORCE)

endfunction()

function(add_bsp_based_library)
    set(options LINK_WHOLE_ARCHIVE)
    set(oneValueArgs BSP_ALIAS NAME)
    set(multiValueArgs SOURCES EXCLUDED_PLATFORMS)

    if("${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
	    message(FATAL_ERROR "Embedded CMake projects must explicitly specify the toolchain")
    endif()
	
    cmake_parse_arguments(_lib "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	
    if("${_lib_BSP_ALIAS}" STREQUAL "")
        set(_lib_BSP_ALIAS BSP)
    endif()

    if("${PLATFORM}" IN_LIST _lib_EXCLUDED_PLATFORMS)
        set(_lib_SOURCES)
	    set(${_lib_NAME}_IS_DUMMY 1 CACHE INTERNAL "")
    else()
    	set(${_lib_NAME}_IS_DUMMY 0 CACHE INTERNAL "")
    endif()

	ensure_at_least_one_source_exists(_lib_SOURCES)

    if(${_lib_LINK_WHOLE_ARCHIVE})
    	add_library(${_lib_NAME} OBJECT ${_lib_SOURCES})
    else()
    	add_library(${_lib_NAME} STATIC ${_lib_SOURCES})
    endif()

	target_link_libraries(${_lib_NAME} PRIVATE  ${${_lib_BSP_ALIAS}_LIBRARIES})

    copy_property_if_not_defined(${_lib_BSP_ALIAS} ${_lib_NAME} C_STANDARD)
    copy_property_if_not_defined(${_lib_BSP_ALIAS} ${_lib_NAME} CXX_STANDARD)

	set(${_lib_BSP_ALIAS}_ASSOCIATED_TARGETS ${${_lib_BSP_ALIAS}_ASSOCIATED_TARGETS} ${_lib_NAME} PARENT_SCOPE)
    add_coverage_flags_and_targets(${_lib_BSP_ALIAS} ${_lib_NAME})
	
	set(${_lib_NAME}_BSP_ALIAS ${_lib_BSP_ALIAS} CACHE STRING "Specifies the BSP alias for the ${name} target." FORCE)

    if(${_lib_LINK_WHOLE_ARCHIVE})
        enable_whole_archive_linking(${_lib_NAME})
    endif()

endfunction()

function (set_forced_include_files target mode)
	if("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
		list(LENGTH ARGN _len)
		if (${_len} GREATER 1)
			message(FATAL_ERROR "IAR compiler does not support multiple forced include files. Please create a single file including all other  files.")
		endif()
	endif()

	foreach(file ${ARGN})
		if (NOT(IS_ABSOLUTE ${file}))
			get_filename_component(file ${file} REALPATH)
		endif()

		if(("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC"))
			target_compile_options(${target} ${mode} $<$<COMPILE_LANGUAGE:C>:--preinclude ${file}>)
			target_compile_options(${target} ${mode} $<$<COMPILE_LANGUAGE:CXX>:--preinclude ${file}>)
		else()
			target_compile_options(${target} ${mode} -include ${file})
		endif()
	endforeach()
endfunction()
