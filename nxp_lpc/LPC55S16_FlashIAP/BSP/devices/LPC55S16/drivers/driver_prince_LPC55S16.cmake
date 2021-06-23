if(NOT DRIVER_PRINCE_LPC55S16_INCLUDED)
    
    set(DRIVER_PRINCE_LPC55S16_INCLUDED true CACHE BOOL "driver_prince component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_prince.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC55S16)

    include(driver_puf_LPC55S16)

    include(driver_iap1_LPC55S16)

endif()
