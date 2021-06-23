if(NOT DEVICE_LPC55S16_SYSTEM_LPC55S16_INCLUDED)
    
    set(DEVICE_LPC55S16_SYSTEM_LPC55S16_INCLUDED true CACHE BOOL "device_LPC55S16_system component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/system_LPC55S16.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(device_LPC55S16_CMSIS_LPC55S16)

endif()
