if(NOT DRIVER_FLASHIAP_LPC54628_INCLUDED)
    
    set(DRIVER_FLASHIAP_LPC54628_INCLUDED true CACHE BOOL "driver_flashiap component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_flashiap.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC54628)

endif()
