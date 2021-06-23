
set(_core_hwregister_list_file LPC54628.vgdbdevice)
set(_core_internal_vars REDLINK:VENDOR_ID=NXP REDLINK:DEVICE_ID=LPC54628J512 REDLINK:DEBUG_OPTIONS= REDLINK:CORE_INDEX=0 REDLINK:CORE_COUNT=1)
set(_core_ID LPC54628J512ET180)
set(_core_ldflags --specs=nano.specs --specs=nosys.specs -lm -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard)
set(_core_cflags -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard)
set(_core_defines ARM_MATH_CM4 CPU_LPC54628J512ET180 CPU_LPC54628J512ET180_cm4)
set(_core_includes ${BSP_ROOT}/CMSIS/Include ${BSP_ROOT}/components/lists ${BSP_ROOT}/components/uart ${BSP_ROOT}/devices/LPC54628 ${BSP_ROOT}/devices/LPC54628/drivers)
set(_core_linker_script ${BSP_ROOT}/devices/LPC54628/gcc/LPC54628J512_ram.ld)
set(_core_sources ${BSP_ROOT}/components/lists/fsl_component_generic_list.c ${BSP_ROOT}/components/uart/fsl_adapter_usart.c ${BSP_ROOT}/devices/LPC54628/gcc/startup_LPC54628.S ${BSP_ROOT}/devices/LPC54628/system_LPC54628.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_clock.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_common.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_emc.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_flashiap.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_flexcomm.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_usart.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_inputmux.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_gpio.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_power.c ${BSP_ROOT}/devices/LPC54628/drivers/fsl_reset.c ${BSP_ROOT}/devices/LPC54628/utilities/fsl_sbrk.c ${BSP_ROOT}/CMSIS/Include/cmsis_armcc.h ${BSP_ROOT}/CMSIS/Include/cmsis_armclang.h ${BSP_ROOT}/CMSIS/Include/cmsis_armclang_ltm.h ${BSP_ROOT}/CMSIS/Include/cmsis_gcc.h ${BSP_ROOT}/CMSIS/Include/cmsis_compiler.h ${BSP_ROOT}/CMSIS/Include/cmsis_version.h ${BSP_ROOT}/CMSIS/Include/cmsis_iccarm.h ${BSP_ROOT}/CMSIS/Include/core_cm4.h ${BSP_ROOT}/CMSIS/Include/mpu_armv7.h ${BSP_ROOT}/CMSIS/Include/arm_common_tables.h ${BSP_ROOT}/CMSIS/Include/arm_const_structs.h ${BSP_ROOT}/CMSIS/Include/arm_math.h ${BSP_ROOT}/components/lists/fsl_component_generic_list.h ${BSP_ROOT}/components/uart/fsl_adapter_uart.h ${BSP_ROOT}/devices/LPC54628/fsl_device_registers.h ${BSP_ROOT}/devices/LPC54628/LPC54628.h ${BSP_ROOT}/devices/LPC54628/LPC54628_features.h ${BSP_ROOT}/devices/LPC54628/system_LPC54628.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_clock.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_common.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_emc.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_flashiap.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_flexcomm.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_usart.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_inputmux.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_inputmux_connections.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_gpio.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_iocon.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_power.h ${BSP_ROOT}/devices/LPC54628/drivers/fsl_reset.h)
