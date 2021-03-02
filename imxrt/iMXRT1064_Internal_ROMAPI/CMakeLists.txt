cmake_minimum_required(VERSION 3.15)

project(iMXRT1064_Internal_ROMAPI LANGUAGES C CXX ASM)
include ("${CMAKE_CURRENT_SOURCE_DIR}/visualgdb/root.cmake")

find_bsp(HWREGISTER_LIST_FILE MIMXRT1064.vgdbdevice
	C_STANDARD 99
	SOURCE BSP)

bsp_include_directories(${BSP_ROOT}/boards/evkmimxrt1064/driver_examples/fsl_romapi .)

bsp_compile_definitions(CPU_MIMXRT1064DVL6A
	SDK_DEBUGCONSOLE=1
	XIP_EXTERNAL_FLASH=1
	XIP_BOOT_HEADER_ENABLE=1)

add_bsp_based_executable(NAME iMXRT1064_Internal_ROMAPI
	SOURCES
		main.cpp
		pin_mux.c
		board.c
		clock_config.c
		dcd.c
		pin_mux.h
		board.h
		clock_config.h
		dcd.h
		../../common/FLASHPluginCommon.cpp
	GENERATE_BIN
	GENERATE_MAP)

target_include_directories(iMXRT1064_Internal_ROMAPI PRIVATE ../../common)
