if(NOT DRIVER_FLEXCOMM_LPC55S16_INCLUDED)
    
    set(DRIVER_FLEXCOMM_LPC55S16_INCLUDED true CACHE BOOL "driver_flexcomm component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_flexcomm.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC55S16)

endif()
