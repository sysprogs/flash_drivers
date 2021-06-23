if(NOT DEVICE_LPC54628_SYSTEM_LPC54628_INCLUDED)
    
    set(DEVICE_LPC54628_SYSTEM_LPC54628_INCLUDED true CACHE BOOL "device_LPC54628_system component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/system_LPC54628.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(device_LPC54628_CMSIS_LPC54628)

endif()
