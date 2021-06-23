cmake_minimum_required(VERSION 3.15)

project(LPC54628_FlashIAP LANGUAGES C CXX ASM)

find_bsp(ID com.sysprogs.imported.ksdk2x.LPC54628J512
	VERSION 2.9.0
	MCU LPC54628J512ET180
	CONFIGURATION
		com.sysprogs.imported.ksdk2x.linker_script=devices/LPC54628/gcc/LPC54628J512_ram.ld
		com.sysprogs.bspoptions.arm.floatmode=-mfloat-abi=hard
	FRAMEWORKS
		com.sysprogs.ksdk2x_imported.platform.Include_common.LPC54628
		com.sysprogs.ksdk2x_imported.platform.Include_core_cm4.LPC54628
		com.sysprogs.ksdk2x_imported.platform.Include_dsp.LPC54628
		com.sysprogs.ksdk2x_imported.component.lists.LPC54628
		com.sysprogs.ksdk2x_imported.component.usart_adapter.LPC54628
		com.sysprogs.ksdk2x_imported.device.LPC54628_CMSIS.LPC54628
		com.sysprogs.ksdk2x_imported.device.LPC54628_startup.LPC54628
		com.sysprogs.ksdk2x_imported.device.LPC54628_system.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.clock.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.common.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.emc.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.flashiap.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.flexcomm.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.flexcomm_usart.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.inputmux.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.inputmux_connections.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.lpc_gpio.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.lpc_iocon.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.power.LPC54628
		com.sysprogs.ksdk2x_imported.platform.drivers.reset.LPC54628
		com.sysprogs.ksdk2x_imported.platform.utilities.misc_utilities.LPC54628
	HWREGISTER_LIST_FILE devices/LPC54628/LPC54628.vgdbdevice
	C_STANDARD 99)

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


target_link_libraries(LPC54628_FlashIAP PUBLIC ${BSP_ROOT}/devices/LPC54628/gcc/libpower_hardabi.a)
target_include_directories(LPC54628_FlashIAP PRIVATE ../../common .)