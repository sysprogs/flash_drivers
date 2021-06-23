function (register_source_path_prefix var_name value)
	if(NOT(${var_name} IN_LIST KNOWN_PATH_PREFIX_VARIABLES))
		set(KNOWN_PATH_PREFIX_VARIABLES ${KNOWN_PATH_PREFIX_VARIABLES} ${var_name} CACHE STRING "Specifies the list of variables like 'BSP_ROOT' that will be substituted by the IDE when referencing source files." FORCE)
	endif()
	
	set(${var_name} ${value} CACHE PATH "" FORCE)
endfunction()

function (register_imported_project)
    set(oneValueArgs NAME PATH LEVEL)
    set(multiValueArgs SOURCES)

    cmake_parse_arguments(_prj "" "${oneValueArgs}" "" ${ARGN})
	if("${_prj_LEVEL}" STREQUAL "")
		set(_prj_LEVEL 1)
	endif()

	get_filename_component(_dir ${_prj_PATH} REALPATH)

	foreach(_i RANGE ${_prj_LEVEL})
		get_filename_component(_dir ${_dir} DIRECTORY)
	endforeach()

	register_source_path_prefix(${_prj_NAME}_LOCATION ${_dir})
endfunction()