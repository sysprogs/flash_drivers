#This file provides the find_bsp() function that instantiates the requested BSP, returning a list of targets in the ${ALIAS}_LIBRARIES variable.
#The generated BSP-specific CMake file expects the following variables to be set when including it:
#BSP_ALIAS          - Name of the BSP library (default is 'BSP'). Also used as a prefix for framework libraries.
#BSP_MCU            - ID of the currently selected MCU
#BSP_FRAMEWORKS     - List of the referenced frameworks. Not used directly. Instead, the BSPs check ${BSP_FRAMEWORK_xxx}.
#BSP_CONFIGURATION  - List of "k=v" strings for the BSP and framework configuration. Not used directly. Instead
#                     the file also expects variables like BSP_CONFIGURATION_xxx

#The IDE uses the following variables to navigate dependencies between the targets and BSPs
#	<target name>_BSP_ALIAS  	- specifies the BSP target name for any BSP-based target
#	<BSP alias>_ROOT		 	- specifies the BSP_ROOT
#	<BSP alias>_LINKER_SCRIPT 	- specifies the linker script

include(${CMAKE_CURRENT_LIST_DIR}/coverage.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/prefixes.cmake)

set(DUMMY_SOURCE_FILE "${CMAKE_CURRENT_LIST_DIR}/dummy.c" CACHE INTERNAL "")

function(ensure_at_least_one_source_exists var)
	set(_has_regular_sources 0)
	foreach(_source ${${var}})
		if ("${_source}" MATCHES "(.*)\.(c|cxx|cpp)\$")
			set(_has_regular_sources 1)
			break()
		endif()
	endforeach()

	if(NOT ${_has_regular_sources})
        list(APPEND ${var} "${DUMMY_SOURCE_FILE}")

		#Unless we actually build the dummy file, producing a valid object, CMake will not report us enough information to find all targets referencing this target
		#if(NOT(("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")))
		#	set_source_files_properties("${DUMMY_SOURCE_FILE}" PROPERTIES HEADER_FILE_ONLY TRUE)
		#endif()
    endif()

	set(${var} ${${var}} PARENT_SCOPE)
endfunction()

function(create_bsp_library name)
	ensure_at_least_one_source_exists(_sources)
	
    add_library(${name} OBJECT ${_sources})
	set(${name}_BSP_ALIAS ${BSP_ALIAS} CACHE STRING "Specifies the BSP alias for the ${name} target." FORCE)
endfunction()

#This function is only needed to distinguish stand-alone BSPs from the definition stack
function(create_standalone_bsp_library name)
	create_bsp_library(${name})
endfunction()

function (copy_property_if_not_defined from to property)
	get_property(_to_value TARGET ${to} PROPERTY ${property})
	if ("${_to_value}" STREQUAL "")
		get_property(_from_value TARGET ${from} PROPERTY ${property})
		if (NOT("${_from_value}" STREQUAL ""))
			set_property(TARGET ${to} PROPERTY ${property} ${_from_value})
		endif()		
	endif()
endfunction()

function(set_bsp_core_properties_from_vars name)
    set_property(TARGET ${name} PROPERTY BSP_LINKER_SCRIPT "${_core_linker_script}")
	
	target_include_directories(${name} PUBLIC ${_core_includes})
	target_compile_definitions(${name} PUBLIC ${_core_defines})
	target_compile_options(${name} PUBLIC ${_core_cflags})

	if(NOT ("${_core_forced_includes}" STREQUAL ""))
		if("${VISUALGDB_TOOLCHAIN_SUBTYPE}" STREQUAL "GCC")
			foreach(_inc ${_core_forced_includes})
				target_compile_options(${name} PUBLIC -include ${_inc})
			endforeach()
		else()
			#Automatic handling of forced includes is only supported on GCC
		endif()
	endif()

	target_link_libraries(${name} PUBLIC ${_core_ldflags})
endfunction()

function (append_per_language_flags var languages)
	set(_result ${${var}})

	foreach(_lang ${languages})
		foreach(_arg ${ARGN})
			set(_result ${_result} $<$<COMPILE_LANGUAGE:${_lang}>:${_arg}>)
		endforeach()
	endforeach()

	set(${var} ${_result} PARENT_SCOPE)
endfunction()

#Inputs: BSP_MCU, BSP_MCU_FAMILY
#Outputs: _core_includes/defines/cflags/ldflags/sources/linker_script
function (compute_toolchain_and_bsp_flags)
    set(_includes "")
    set(_defines "")
    set(_cflags "")
    set(_ldflags "")
    set(_sources "")
    set(_linker_script "")
    set(_forced_includes "")
    set(_c_standard "")

	#The functions called below are implemented by a specific toolchain and BSP.
	#Each of them appends a set of flags to the _includes/_defines/etc. variables, that will be attached to the BSP library.
	visualgdb_toolchain_compute_flags()
	
	if("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang")
		#Toolchain-level CFlags for ARMClang projects do not apply to assembler
		set(_scoped_cflags "")
		append_per_language_flags(_scoped_cflags "C;CXX" ${_cflags})
		set(_cflags ${_scoped_cflags})
	endif()

    visualgdb_bsp_compute_mcu_family_flags(${BSP_MCU_FAMILY})
    visualgdb_bsp_compute_mcu_flags(${BSP_MCU})

	if("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
		set(_cflags $<$<COMPILE_LANGUAGE:C>:${_cflags}> $<$<COMPILE_LANGUAGE:CXX>:${_cflags}>)
	elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC")
		set(_cflags ${_cflags} ${_keil_armcc_flags})
		set(_ldflags ${_ldflags} ${_keil_armcc_flags})
	elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang")
		append_per_language_flags(_cflags ASM ${_keil_armcc_flags})
		append_per_language_flags(_cflags "C;CXX" ${_keil_armclang_flags})
		set(_ldflags ${_ldflags} ${_keil_armcc_flags})
	endif()

	if(("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang"))
	    set(_keil_base_flags ${_keil_base_flags} PARENT_SCOPE)
	endif()
	
    visualgdb_bsp_compute_conditional_flags()

    set(_core_includes "${_includes}" PARENT_SCOPE)
    set(_core_defines "${_defines}" PARENT_SCOPE)
    set(_core_cflags "${_cflags}" PARENT_SCOPE)
    set(_core_ldflags "${_ldflags}" PARENT_SCOPE)
    set(_core_sources "${_sources}" PARENT_SCOPE)
    set(_core_linker_script "${_linker_script}" PARENT_SCOPE)
    set(_core_forced_includes "${_forced_includes}" PARENT_SCOPE)
    set(_core_c_standard "${_c_standard}" PARENT_SCOPE)

    set(_keil_entry_point ${_keil_entry_point} PARENT_SCOPE)
    set(_keil_first_symbol ${_keil_first_symbol} PARENT_SCOPE)
endfunction()

function (enable_whole_archive_linking _lib)
	get_target_property(_type ${_lib} TYPE)

	if("${_type}" STREQUAL "STATIC_LIBRARY")
		if("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
			set_target_properties(${_lib} PROPERTIES SPELLING_NAME_PREFIX --whole_archive)
		else()
			set_target_properties(${_lib} PROPERTIES SPELLING_NAME_PREFIX -Wl,--whole-archive SPELLING_NAME_SUFFIX -Wl,--no-whole-archive)
		endif()
	endif()
endfunction()

function(find_bsp)
    set(options NO_GC_SECTIONS ENABLE_EXCEPTIONS ENABLE_RTTI DUMP_STACK_USAGE ARMCLANG_PROCESSOR)
    set(oneValueArgs ID VERSION ALIAS MCU SOURCE HWREGISTER_LIST_FILE C_STANDARD CXX_STANDARD SOURCE_PROJECT EXPLICIT_LOCATION)
    set(multiValueArgs FRAMEWORKS CONFIGURATION FWCONFIGURATION)

	#Note: HWREGISTER_LIST_FILE is only used by the IDE & debugging logic and is stored in CMakeLists.txt for convenience.
	
    cmake_parse_arguments(BSP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if("${BSP_ALIAS}" STREQUAL "")
        set(BSP_ALIAS BSP)
    endif()

    foreach(kv ${BSP_CONFIGURATION} ${BSP_FWCONFIGURATION})
		string(REGEX REPLACE "^[ ]+" "" kv ${kv})
		string(REGEX MATCH "^[^=]+" Key ${kv})
		string(REPLACE "${Key}=" "" Value ${kv})
		set(BSP_CONFIGURATION_${Key} "${Value}")
    endforeach()
	
	foreach(fw ${BSP_FRAMEWORKS})
		set(BSP_FRAMEWORK_${fw} 1)
	endforeach()

	if(NOT ("${BSP_EXPLICIT_LOCATION}" STREQUAL ""))
		set(BSP_ROOT ${BSP_EXPLICIT_LOCATION})

		if (NOT(IS_ABSOLUTE ${BSP_ROOT}))
			set(BSP_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/${BSP_ROOT})
		endif()

		if(NOT EXISTS "${BSP_ROOT}/bsp.cmake")
			message(FATAL_ERROR "BSP directory does not contain BSP.cmake")
		endif()
	endif()
	
	set(_load_regular_bsps 1)
	
	if((NOT ("${BSP_EXPLICIT_LOCATION}" STREQUAL "")) OR (NOT ("${BSP_SOURCE}" STREQUAL "")))
		if("${VISUALGDB_COMPONENT_LISTS_DIR}" STREQUAL "")
			set(_load_regular_bsps 0)
		endif()
	endif()
	
	if (${_load_regular_bsps})
		if("${VISUALGDB_COMPONENT_LISTS_DIR}" STREQUAL "")
			message(FATAL_ERROR "VisualGDB component list directory must be set in the toolchain file")
		endif()

		if(NOT EXISTS "${VISUALGDB_COMPONENT_LISTS_DIR}/FindBSP.cmake")
			message(FATAL_ERROR "BSP list file is unspecified or missing")
		endif()

		include("${VISUALGDB_COMPONENT_LISTS_DIR}/FindBSP.cmake")
	endif()
	
	
	if(SIMULATION)
		#This is the emulation-only platform. BSP_ROOT should not match any real folder.
		set(BSP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/__SIMULATION__")

		set(_core_defines SIMULATION)
	elseif(NOT ("${BSP_SOURCE_PROJECT}" STREQUAL ""))
		set(BSP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}")
		
		set(_bsp_mak "${CMAKE_CURRENT_BINARY_DIR}/${BSP_ALIAS}.cmake")

		get_filename_component(_project_path ${BSP_SOURCE_PROJECT} REALPATH)
		set(_${BSP_ALIAS}_CONFIGURABLE_PROJECT ${_project_path} CACHE INTERNAL "")
		set(_${BSP_ALIAS}_GENERATED_PROJECT_PROFILE ${_bsp_mak} CACHE INTERNAL "")
		set(_${BSP_ALIAS}_CONFIGURATOR_ID ${BSP_ID} CACHE INTERNAL "")
				
		if (NOT EXISTS "${_bsp_mak}")
			exec_program(cmd.exe $ENV{VISUALGDB_DIR} ARGS /c VisualGDB.exe /prj2cmake "\"${CMAKE_CURRENT_SOURCE_DIR}\"" "${BSP_ID}" "\"${BSP_SOURCE_PROJECT}\"" "\"${_bsp_mak}\"")
		endif()

		include ("${_bsp_mak}")

		set(BSP_MCU ${_core_ID})
	elseif("${BSP_SOURCE}" STREQUAL "")
		#This is a regular BSP installed by VisualGDB. Locate and include its definition.

		if("${BSP_ID}" STREQUAL "")
			message(FATAL_ERROR "BSP ID is not specified when calling find_bsp()")
		endif()

		if(("${BSP_ROOT}" STREQUAL "") AND (DEFINED TOOLCHAIN_HAS_BUILTIN_BSPS))
			visualgdb_toolchain_find_builtin_bsp()
		endif()

		if("${BSP_ROOT}" STREQUAL "")
			message(FATAL_ERROR "Could not find a BSP with ID = ${BSP_ID} and Version = ${BSP_VERSION}")
		endif()

		if(NOT EXISTS "${BSP_ROOT}/bsp.cmake")
			message(FATAL_ERROR "Missing ${BSP_ROOT}/bsp.cmake. Please reopen the project with VisualGDB.")
		endif()

		include("${BSP_ROOT}/bsp.cmake")

		visualgdb_toolchain_load_default_configuration()

		#Inputs: BSP_MCU, BSP_FRAMEWORK_xxx
		#Outputs: BSP_CONFIGURATION_xxx from AdditionalSystemVars, _bsp_variables containing the list of all variables
		visualgdb_bsp_load_system_variables()

		set(_${BSP_ALIAS}_VARIABLES ${_bsp_variables} CACHE INTERNAL "")
		foreach(_var ${_bsp_variables})
			set(_${BSP_ALIAS}_${_var} ${${_var}} CACHE INTERNAL "")
		endforeach()

		#This loads the system variables (e.g. default configuration for the embedded frameworks)
		visualgdb_bsp_load_referenced_frameworks()

		#Inputs: BSP_MCU
		#Outputs: _core_sources/includes/defines/cflags/ldflags/linker_script
		compute_toolchain_and_bsp_flags()
	else()
		#This is an in-place BSP
		set(BSP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/${BSP_SOURCE}")
				
		if(NOT EXISTS "${BSP_ROOT}/bsp.cmake")
			message(FATAL_ERROR "Missing ${BSP_ROOT}/bsp.cmake. Please reopen the project with VisualGDB.")
		endif()

		include ("${BSP_ROOT}/bsp.cmake")
	endif()

	if(NOT BSP_NO_GC_SECTIONS)
		if("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC")
			append_per_language_flags(_core_cflags "C;CXX" --split-sections)
		elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
		elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMClang")
			append_per_language_flags(_core_cflags "C;CXX" -ffunction-sections -fdata-sections)
		else()
			set(_core_cflags ${_core_cflags} -ffunction-sections -fdata-sections)
			set(_core_ldflags ${_core_ldflags} -Wl,-gc-sections)
		endif()
	endif()

	#This creates the library, but doesn't set the properties on it yet, as the frameworks may modify them.
	set(_sources ${_core_sources})

	if("${BSP_SOURCE}" STREQUAL "")
		create_bsp_library(${BSP_ALIAS})
	else()
		#VisualGDB recognizes stand-alone BSPs from the definition stack
		create_standalone_bsp_library(${BSP_ALIAS})
	endif()

	if (${BSP_C_STANDARD})
		set_property(TARGET ${BSP_ALIAS} PROPERTY C_STANDARD ${BSP_C_STANDARD})
	elseif(${_core_c_standard})
		set_property(TARGET ${BSP_ALIAS} PROPERTY C_STANDARD ${_core_c_standard})
	endif()

	if (${BSP_CXX_STANDARD})
		set_property(TARGET ${BSP_ALIAS} PROPERTY CXX_STANDARD ${BSP_CXX_STANDARD})
	endif()

	if("${CMAKE_C_COMPILER_ID}" STREQUAL "ARMCC")
	elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "IAR")
	else()
		if(NOT ${BSP_ENABLE_EXCEPTIONS})
			target_compile_options(${BSP_ALIAS} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>)
		endif()

		if(NOT ${BSP_ENABLE_RTTI})
			target_compile_options(${BSP_ALIAS} PUBLIC $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>)
		endif()
	endif()

	if(${BSP_DUMP_STACK_USAGE})
	    target_compile_options(${BSP_ALIAS} PUBLIC -fstack-usage)
	endif()
	
	if(("${BSP_SOURCE}" STREQUAL "") AND ("${BSP_SOURCE_PROJECT}" STREQUAL "") AND NOT ${SIMULATION})
		#This creates framework libraries that reference the core library.
		#Updates: _core_includes _core_defines
		#Outputs: _framework_libraries

		visualgdb_bsp_instantiate_referenced_frameworks()
	endif()
	
	#This will create libraries for out-of-BSP frameworks (e.g. profiler)
	if ((NOT ${SIMULATION}) AND NOT ("${VISUALGDB_COMPONENT_LISTS_DIR}" STREQUAL ""))
		visualgdb_instantiate_external_frameworks()
	endif()

	if(${HAS_KEIL_COMPONENTS})
		visualgdb_bsp_instantiate_keil_components()
	endif()
	
	#This sets properties on the BSP library based on the BSP itself and the libraries
	set_bsp_core_properties_from_vars(${BSP_ALIAS})
	
	foreach(_lib ${_framework_libraries})
		copy_property_if_not_defined(${BSP_ALIAS} ${_lib} C_STANDARD)
		copy_property_if_not_defined(${BSP_ALIAS} ${_lib} CXX_STANDARD)
	endforeach()

	set(${BSP_ALIAS}_ASSOCIATED_TARGETS ${_framework_libraries} PARENT_SCOPE)
	
	#BSP libraries may redefine library functions, such as _sbrk(), so we need to ensure they get linked with the --whole-archive option.

	foreach(_lib ${BSP_ALIAS} ${_framework_libraries})
		enable_whole_archive_linking(${_lib})
	endforeach()
	
	set(${BSP_ALIAS}_LIBRARIES ${BSP_ALIAS} ${_framework_libraries} PARENT_SCOPE)
	set(${BSP_ALIAS}_LINKER_SCRIPT "${_core_linker_script}" CACHE FILEPATH "Default linker script for ${BSP_ALIAS}. Used by the VisualGDB GUI." FORCE)

	set(_${BSP_ALIAS}_ID ${BSP_ID} CACHE INTERNAL "")
	set(_${BSP_ALIAS}_VERSION ${BSP_VERSION} CACHE INTERNAL "")
	set(_${BSP_ALIAS}_MCU ${BSP_MCU} CACHE INTERNAL "")
	set(_${BSP_ALIAS}_ROOT ${BSP_ROOT} CACHE INTERNAL "")
	set(_${BSP_ALIAS}_EXPLICIT_LOCATION ${BSP_EXPLICIT_LOCATION} CACHE INTERNAL "")

	set(${BSP_ALIAS}_IS_DUMMY ${SIMULATION} CACHE INTERNAL "")

	if(NOT("${BSP_SOURCE}" STREQUAL ""))
		get_filename_component(_full_source ${BSP_SOURCE} REALPATH)
		set(_${BSP_ALIAS}_SOURCE ${_full_source} CACHE INTERNAL "")
	endif()

	set_target_properties(${BSP_ALIAS} PROPERTIES DEFAULT_ENTRY_POINT "${_keil_entry_point}" DEFAULT_FIRST_SYMBOL "${_keil_first_symbol}" KEIL_BASE_FLAGS "${_keil_base_flags}")
	
	register_source_path_prefix(${BSP_ALIAS}_ROOT ${BSP_ROOT})
endfunction()

function(bsp_include_directories)
    cmake_parse_arguments(BSP "" "ALIAS" "" ${ARGN})

    if("${BSP_ALIAS}" STREQUAL "")
        set(BSP_ALIAS BSP)
    endif()

	target_include_directories(${BSP_ALIAS} PUBLIC ${BSP_UNPARSED_ARGUMENTS})
endfunction()

function(bsp_compile_definitions)
    cmake_parse_arguments(BSP "" "ALIAS" "" ${ARGN})

    if("${BSP_ALIAS}" STREQUAL "")
        set(BSP_ALIAS BSP)
    endif()

	target_compile_definitions(${BSP_ALIAS} PUBLIC ${BSP_UNPARSED_ARGUMENTS})
endfunction()

function(bsp_compile_flags)
    cmake_parse_arguments(BSP "" "ALIAS" "" ${ARGN})

    if("${BSP_ALIAS}" STREQUAL "")
        set(BSP_ALIAS BSP)
    endif()

	target_compile_options(${BSP_ALIAS} PUBLIC ${BSP_UNPARSED_ARGUMENTS})
endfunction()

function(bsp_linker_flags)
    cmake_parse_arguments(BSP "" "ALIAS" "" ${ARGN})

    if("${BSP_ALIAS}" STREQUAL "")
        set(BSP_ALIAS BSP)
    endif()

	target_link_libraries(${BSP_ALIAS} PUBLIC ${BSP_UNPARSED_ARGUMENTS})
endfunction()
