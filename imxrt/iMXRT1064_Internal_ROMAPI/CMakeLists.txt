cmake_minimum_required(VERSION 3.15)

project(iMXRT1064_Internal_ROMAPI LANGUAGES C CXX ASM)

find_bsp(ID com.sysprogs.imported.ksdk2x.MIMXRT1064xxxxA
	VERSION 2.9.1
	MCU MIMXRT1064DVL6A
	CONFIGURATION
		com.sysprogs.imported.ksdk2x.linker_script=devices/MIMXRT1064/gcc/MIMXRT1064xxxxx_ram.ld
		com.sysprogs.bspoptions.arm.floatmode=-mfloat-abi=hard
	FRAMEWORKS
		com.sysprogs.ksdk2x_imported.platform.Include_common.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.Include_core_cm7.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.Include_dsp.MIMXRT1064
		com.sysprogs.ksdk2x_imported.component.lists.MIMXRT1064
		com.sysprogs.ksdk2x_imported.device.MIMXRT1064_CMSIS.MIMXRT1064
		com.sysprogs.ksdk2x_imported.device.MIMXRT1064_startup.MIMXRT1064
		com.sysprogs.ksdk2x_imported.device.MIMXRT1064_system.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.cache_armv7_m7.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.clock.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.common.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.igpio.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.iomuxc.MIMXRT1064
		com.sysprogs.ksdk2x_imported.driver.romapi.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.xip_board.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.drivers.xip_device.MIMXRT1064
		com.sysprogs.ksdk2x_imported.platform.utilities.misc_utilities.MIMXRT1064
	HWREGISTER_LIST_FILE devices/MIMXRT1064/MIMXRT1064.vgdbdevice
	C_STANDARD 99)

bsp_include_directories(${BSP_ROOT}/boards/evkmimxrt1064/driver_examples/fsl_romapi)

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

target_include_directories(iMXRT1064_Internal_ROMAPI PRIVATE ../../common .)
