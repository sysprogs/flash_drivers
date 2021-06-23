cmake_minimum_required(VERSION 3.15)

project(LPC55S16_FlashIAP LANGUAGES C CXX ASM)

find_bsp(ID com.sysprogs.imported.ksdk2x.LPC55S16
	VERSION 2.9.1
	MCU LPC55S16JBD100
	CONFIGURATION
		com.sysprogs.imported.ksdk2x.linker_script=devices/LPC55S16/gcc/LPC55S16_ram.ld
		com.sysprogs.bspoptions.arm.floatmode=-mfloat-abi=hard
	FRAMEWORKS
		com.sysprogs.ksdk2x_imported.platform.Include_common.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.Include_core_cm33.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.Include_dsp.LPC55S16
		com.sysprogs.ksdk2x_imported.component.lists.LPC55S16
		com.sysprogs.ksdk2x_imported.component.usart_adapter.LPC55S16
		com.sysprogs.ksdk2x_imported.device.LPC55S16_CMSIS.LPC55S16
		com.sysprogs.ksdk2x_imported.device.LPC55S16_startup.LPC55S16
		com.sysprogs.ksdk2x_imported.device.LPC55S16_system.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.clock.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.common.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.flexcomm.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.flexcomm_usart.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.iap1.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.inputmux.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.inputmux_connections.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.lpc_gpio.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.lpc_iocon.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.power.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.drivers.reset.LPC55S16
		com.sysprogs.ksdk2x_imported.platform.utilities.misc_utilities.LPC55S16
	HWREGISTER_LIST_FILE devices/LPC55S16/LPC55S16.vgdbdevice
	C_STANDARD 99)

bsp_include_directories(${BSP_ROOT}/boards/lpcxpresso55s16/driver_examples/flashiap)

bsp_compile_definitions(CPU_LPC55S16JBD100)

add_bsp_based_executable(NAME LPC55S16_FlashIAP
	SOURCES main.cpp clock_config.c clock_config.h ../../common/FLASHPluginCommon.cpp
	GENERATE_BIN
	GENERATE_MAP)

target_link_libraries(LPC55S16_FlashIAP PUBLIC ${BSP_ROOT}/devices/LPC55S16/gcc/libpower_hardabi.a)
target_include_directories(LPC55S16_FlashIAP PRIVATE ../../common .)