if(NOT DRIVER_CLOCK_LPC55S16_INCLUDED)
    
    set(DRIVER_CLOCK_LPC55S16_INCLUDED true CACHE BOOL "driver_clock component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_clock.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    #OR Logic component
    if(CONFIG_USE_driver_power_LPC55S16)
         include(driver_power_LPC55S16)
    endif()
    if(CONFIG_USE_driver_power_s_LPC55S16)
         include(driver_power_s_LPC55S16)
    endif()
    if(NOT (CONFIG_USE_driver_power_LPC55S16 OR CONFIG_USE_driver_power_s_LPC55S16))
        message(WARNING "Since driver_power_LPC55S16/driver_power_s_LPC55S16 is not included at first or config in config.cmake file, use driver_power_LPC55S16 by default.")
        include(driver_power_LPC55S16)
    endif()

    include(driver_common_LPC55S16)

endif()
