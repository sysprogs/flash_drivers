if(NOT DRIVER_CMSIS_LPC_GPIO_LPC54628_INCLUDED)
    
    set(DRIVER_CMSIS_LPC_GPIO_LPC54628_INCLUDED true CACHE BOOL "driver_cmsis_lpc_gpio component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_gpio_cmsis.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_lpc_gpio_LPC54628)

    include(driver_pint_LPC54628)

    include(CMSIS_Driver_Include_GPIO_LPC54628)

endif()
