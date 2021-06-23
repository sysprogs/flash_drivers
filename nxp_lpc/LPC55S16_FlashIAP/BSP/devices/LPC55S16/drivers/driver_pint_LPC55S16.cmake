if(NOT DRIVER_PINT_LPC55S16_INCLUDED)
    
    set(DRIVER_PINT_LPC55S16_INCLUDED true CACHE BOOL "driver_pint component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_pint.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC55S16)

endif()
