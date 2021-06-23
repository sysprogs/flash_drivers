set(SYSPROGS_RESOURCE_FILE_TEMPLATE ${CMAKE_CURRENT_LIST_DIR}/resources.h)

function(create_embedded_resource_target name file)
	add_custom_target(${name} DEPENDS ${file}.o)
endfunction()

function(add_embedded_resource)
    set(options FORCE_LINK)
    set(oneValueArgs SOURCE NAME SECTION GENERATED_HEADER)
    set(multiValueArgs TARGETS)
	
    cmake_parse_arguments(_res "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if("${_res_SECTION}" STREQUAL "")
        set(_res_SECTION .rodata)
    endif()
	
    if("${_res_GENERATED_HEADER}" STREQUAL "")
        set(_res_GENERATED_HEADER "EmbeddedResources.h")
    endif()

	get_filename_component(_res_path ${_res_SOURCE} REALPATH)
	string(MAKE_C_IDENTIFIER ${_res_path} _res_id)
	set(_res_id "_binary_${_res_id}")

	set(_res_sym ${_res_NAME})
	set(_res_GENERATED_HEADER_DIRECTORY ResourceHeaders)

	add_custom_command(OUTPUT ${_res_NAME}.o0 
		COMMAND ${CMAKE_LD} 
		ARGS -r -b binary ${_res_path} -o ${CMAKE_CURRENT_BINARY_DIR}/${_res_NAME}.o0
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} 
		DEPENDS ${_res_path}
		COMMENT "Wrapping ${_res_SOURCE}")

	add_custom_command(OUTPUT ${_res_NAME}.o 
		COMMAND ${CMAKE_OBJCOPY} 
		ARGS --rename-section .data=${_res_SECTION}
			 --redefine-sym ${_res_id}_start=${_res_sym}_start
			 --redefine-sym ${_res_id}_end=${_res_sym}_end
			 --redefine-sym ${_res_id}_size=${_res_sym}_size
			 ${_res_NAME}.o0 ${_res_NAME}.o 
		DEPENDS ${_res_NAME}.o0 
		COMMENT "Moving ${_res_NAME} to ${_res_SECTION}")
	
	set_source_files_properties(${CMAKE_CURRENT_BINARY_DIR}/${_res_NAME}.o PROPERTIES EXTERNAL_OBJECT true GENERATED true)

	create_embedded_resource_target(${_res_NAME} ${_res_NAME}.o)
	
	if (NOT(TARGET ${_res_GENERATED_HEADER}))
		add_custom_target(${_res_GENERATED_HEADER} 
			COMMENT "Updating ${_res_GENERATED_HEADER}"
			COMMAND $ENV{VISUALGDB_DIR}/VisualGDB.exe /resourcehdr ${_res_GENERATED_HEADER_DIRECTORY}/${_res_GENERATED_HEADER} $<TARGET_PROPERTY:${_res_GENERATED_HEADER},RESOURCE_NAMES>)

		set_property(TARGET ${_res_GENERATED_HEADER} PROPERTY RESOURCE_NAMES "")
	endif()

	foreach(_target ${_res_TARGETS})
		target_sources(${_target} PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/${_res_NAME}.o)
		add_dependencies(${_target} ${_res_GENERATED_HEADER})
		target_include_directories(${_target} PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/${_res_GENERATED_HEADER_DIRECTORY})

		if (${_res_FORCE_LINK})
			target_link_libraries(${_target} PUBLIC -Wl,-undefined=${_res_sym}_start -Wl,-undefined=${_res_sym}_end -Wl,-undefined=${_res_sym}_size)
		endif()
		
		get_target_property(_tgt_resources ${_target} REFERENCED_RESOURCES)
		if ("${_tgt_resources}" STREQUAL "_tgt_resources-NOTFOUND")
			set(_tgt_resources "")
		endif()

		set_property(TARGET ${_target} PROPERTY REFERENCED_RESOURCES ${_tgt_resources} ${_res_NAME})

		set(${_target}_REFERENCED_RESOURCES ${_tgt_resources} ${_res_NAME} CACHE INTERNAL "")
	endforeach()

	#This allows generating resource headers
	get_target_property(_rcnames ${_res_GENERATED_HEADER} RESOURCE_NAMES)
	set_property(TARGET ${_res_GENERATED_HEADER} PROPERTY RESOURCE_NAMES ${_rcnames} ${_res_sym})

	set(${_res_NAME}_SOURCE_FILE ${_res_path} CACHE INTERNAL "")

	get_filename_component(_res_header ${CMAKE_CURRENT_BINARY_DIR}/${_res_GENERATED_HEADER_DIRECTORY}/${_res_GENERATED_HEADER} REALPATH)
	set(${_res_NAME}_RESOURCE_HEADER ${_res_header} CACHE INTERNAL "")
	set(${_res_NAME}_SECTION ${_res_SECTION} CACHE INTERNAL "")

endfunction()

function (embed_target_output)
    set(options)
    set(oneValueArgs FROM_TARGET SECTION GENERATED_HEADER)
    set(multiValueArgs IN_TARGETS)
	
    cmake_parse_arguments(_res "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	if ("${_res_FROM_TARGET}" STREQUAL "")
		message(FATAL_ERROR "Missing 'from' target in embed_target_output()")
	endif()

	if ("${_res_IN_TARGETS}" STREQUAL "")
		message(FATAL_ERROR "Missing 'in' target in embed_target_output()")
	endif()

	if (NOT(TARGET ${_res_FROM_TARGET}-bin))
		message(FATAL_ERROR "The ${_res_FROM_TARGET} does not produce a binary file. Add 'GENERATE_BIN' to add_bsp_based_executable()")
	endif()

	get_target_property(_bin ${_res_FROM_TARGET} GENERATED_BINARY_FILE)
	get_filename_component(_bin ${_bin} REALPATH)

	set(_res_NAME ${_res_FROM_TARGET}_embedded_bin)

	add_embedded_resource(NAME ${_res_NAME}
		SOURCE ${_bin}
		SECTION ${_res_SECTION}
		GENERATED_HEADER ${_res_GENERATED_HEADER}
		TARGETS ${_res_IN_TARGETS})

	set(${_res_NAME}_SOURCE_TARGET ${_res_FROM_TARGET} CACHE INTERNAL "")
endfunction()