cmake_minimum_required(VERSION 3.15)

project(LPC55S16_FlashIAP LANGUAGES C CXX ASM)

find_bsp(HWREGISTER_LIST_FILE LPC55S16.vgdbdevice
	C_STANDARD 99
	SOURCE BSP 
	ALIAS BSP_LPCS5516)

bsp_include_directories(${BSP_ROOT}/boards/lpcxpresso55s16/driver_examples/flashiap)

bsp_compile_definitions(CPU_LPC55S16JBD100)

add_bsp_based_executable(NAME LPC55S16_FlashIAP
	SOURCES main.cpp clock_config.c clock_config.h ../../common/FLASHPluginCommon.cpp
	BSP_ALIAS BSP_LPCS5516
	GENERATE_BIN
	GENERATE_MAP)

target_include_directories(LPC55S16_FlashIAP PRIVATE ../../common .)
target_link_libraries(LPC55S16_FlashIAP PUBLIC ${BSP_LPCS5516_ROOT}/devices/LPC55S16/gcc/libpower_hardabi.a)
