cmake_minimum_required(VERSION 3.15)

project(LPC54628_FlashIAP LANGUAGES C CXX ASM)

find_bsp(HWREGISTER_LIST_FILE LPC54628.vgdbdevice
	C_STANDARD 99
	SOURCE BSP)

bsp_include_directories(${BSP_ROOT}/boards/lpcxpresso54628/driver_examples/flashiap)

bsp_compile_definitions(CPU_LPC54628
	__USE_CMSIS
	CPU_LPC54628J512ET180=1)

add_bsp_based_executable(NAME LPC54628_FlashIAP
	SOURCES
		main.cpp
		clock_config.c
		clock_config.h
		../../common/FLASHPluginCommon.cpp
		FLASHPluginConfig.h
	GENERATE_BIN
	GENERATE_MAP)


target_include_directories(LPC54628_FlashIAP PRIVATE ../../common .)
target_link_libraries(LPC54628_FlashIAP PUBLIC ${BSP_ROOT}/devices/LPC54628/gcc/libpower_hardabi.a)