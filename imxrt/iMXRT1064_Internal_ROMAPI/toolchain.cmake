SET(CMAKE_SYSTEM_NAME Generic)
SET(VISUALGDB_TOOLCHAIN_TYPE Embedded)
SET(VISUALGDB_TOOLCHAIN_SUBTYPE GCC)

SET(CMAKE_C_COMPILER "arm-none-eabi-gcc")
SET(CMAKE_CXX_COMPILER "arm-none-eabi-g++")
SET(CMAKE_ASM_COMPILER "arm-none-eabi-g++")
SET(CMAKE_LD "arm-none-eabi-ld")

#Barebone toolchain cannot link executables without a device-specific linker script
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_OBJECT_PATH_MAX 200)
set(KNOWN_PATH_PREFIX_VARIABLES "" CACHE STRING "Specifies the list of variables like 'BSP_ROOT' that will be substituted by the IDE when referencing source files." FORCE)

function (visualgdb_toolchain_load_default_configuration)
    if(NOT DEFINED BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.libctype)
        set(BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.libctype "--specs=nano.specs")
        set(BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.libctype "${BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.libctype}" PARENT_SCOPE)
    endif()

    if(NOT DEFINED BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.syscallspecs)
        set(BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.syscallspecs "--specs=nosys.specs")
        set(BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.syscallspecs "${BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.syscallspecs}" PARENT_SCOPE)
    endif()

endfunction() #visualgdb_toolchain_load_default_configuration

function (visualgdb_toolchain_compute_flags)
    set(_includes "${_includes}" PARENT_SCOPE)
    set(_defines "${_defines}" PARENT_SCOPE)
    set(_cflags "${_cflags}" PARENT_SCOPE)
    set(_ldflags ${_ldflags} "${BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.libctype}" "${BSP_CONFIGURATION_com.sysprogs.toolchainoptions.arm.syscallspecs}")
    set(_ldflags "${_ldflags}" PARENT_SCOPE)
endfunction() #visualgdb_toolchain_compute_flags


