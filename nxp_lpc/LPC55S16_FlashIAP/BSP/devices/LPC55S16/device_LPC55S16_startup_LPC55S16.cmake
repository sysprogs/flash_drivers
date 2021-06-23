if(NOT DEVICE_LPC55S16_STARTUP_LPC55S16_INCLUDED)
    
    set(DEVICE_LPC55S16_STARTUP_LPC55S16_INCLUDED true CACHE BOOL "device_LPC55S16_startup component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/gcc/startup_LPC55S16.S
    )


    include(device_LPC55S16_system_LPC55S16)

endif()
