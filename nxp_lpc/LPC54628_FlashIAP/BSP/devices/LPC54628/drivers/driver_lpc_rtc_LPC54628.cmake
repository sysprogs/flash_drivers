if(NOT DRIVER_LPC_RTC_LPC54628_INCLUDED)
    
    set(DRIVER_LPC_RTC_LPC54628_INCLUDED true CACHE BOOL "driver_lpc_rtc component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_rtc.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC54628)

endif()
