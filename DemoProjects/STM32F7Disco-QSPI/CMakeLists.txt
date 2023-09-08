cmake_minimum_required(VERSION 3.15)

project(QSPIDemo LANGUAGES C CXX ASM)

find_bsp(
	ID com.sysprogs.arm.stm32
	VERSION 2023.07
	MCU STM32F746NG
	FRAMEWORKS com.sysprogs.arm.stm32.hal com.sysprogs.arm.stm32.ll
	HWREGISTER_LIST_FILE STM32F7xxxx/DeviceDefinitions/stm32f746xx.xml
	DISABLE_GNU_EXTENSIONS)

add_bsp_based_executable(
	NAME QSPIDemo
	SOURCES QSPIDemo.cpp system_stm32f7xx.c stm32f7xx_hal_conf.h QSPIRoutines.cpp
	GENERATE_MAP
	LINKER_SCRIPT STM32F746NG_flash.lds
	MEMORY_LIST_FILE ExtraMemories)
