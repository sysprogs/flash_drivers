if(NOT DEVICE_LPC54628_STARTUP_LPC54628_INCLUDED)
    
    set(DEVICE_LPC54628_STARTUP_LPC54628_INCLUDED true CACHE BOOL "device_LPC54628_startup component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/gcc/startup_LPC54628.S
    )


    include(device_LPC54628_system_LPC54628)

endif()
