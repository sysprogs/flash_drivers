cmake_minimum_required(VERSION 3.15)

project(iMXRT1050_HyperFLASH LANGUAGES C CXX ASM)

find_bsp(ID com.sysprogs.imported.ksdk2x.MIMXRT1052xxxxB
	VERSION 2.9.1
	MCU MIMXRT1052DVL6B
	CONFIGURATION com.sysprogs.imported.ksdk2x.linker_script=devices/MIMXRT1052/gcc/MIMXRT1052xxxxx_ram.ld
	FRAMEWORKS
		com.sysprogs.ksdk2x_imported.utility.debug_console_lite.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.utilities.assert_lite.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.flexspi.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.cache_armv7_m7.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.clock.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.common.MIMXRT1052
		com.sysprogs.ksdk2x_imported.device.MIMXRT1052_CMSIS.MIMXRT1052
		com.sysprogs.ksdk2x_imported.component.lpuart_adapter.MIMXRT1052
		com.sysprogs.ksdk2x_imported.component.lists.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.lpuart.MIMXRT1052
		com.sysprogs.ksdk2x_imported.device.MIMXRT1052_startup.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.iomuxc.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.igpio.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.xip_device.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.drivers.xip_board.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.Include_core_cm7.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.Include_common.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.Include_dsp.MIMXRT1052
		com.sysprogs.ksdk2x_imported.platform.utilities.misc_utilities.MIMXRT1052
		com.sysprogs.ksdk2x_imported.device.MIMXRT1052_system.MIMXRT1052
	HWREGISTER_LIST_FILE devices/MIMXRT1052/MIMXRT1052.vgdbdevice
	C_STANDARD 99)

bsp_include_directories(${BSP_ROOT}/boards/evkbimxrt1050/driver_examples/flexspi/hyper_flash/polling_transfer)

bsp_compile_definitions(CPU_MIMXRT1052DVL6B
	SDK_DEBUGCONSOLE=1
	XIP_EXTERNAL_FLASH=1
	XIP_BOOT_HEADER_ENABLE=1)

add_bsp_based_executable(NAME iMXRT1050_HyperFLASH
	SOURCES
		flexspi_hyper_flash_polling_transfer.c
		flexspi_hyper_flash_ops.c
		pin_mux.c
		board.c
		clock_config.c
		dcd.c
		app.h
		pin_mux.h
		board.h
		clock_config.h
		dcd.h
	GENERATE_BIN
	GENERATE_MAP)
