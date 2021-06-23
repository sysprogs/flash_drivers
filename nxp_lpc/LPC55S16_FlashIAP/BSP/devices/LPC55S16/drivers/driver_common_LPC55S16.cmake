if(NOT DRIVER_COMMON_LPC55S16_INCLUDED)
    
    set(DRIVER_COMMON_LPC55S16_INCLUDED true CACHE BOOL "driver_common component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_common.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_clock_LPC55S16)

    include(device_LPC55S16_CMSIS_LPC55S16)

    include(driver_reset_LPC55S16)

endif()
