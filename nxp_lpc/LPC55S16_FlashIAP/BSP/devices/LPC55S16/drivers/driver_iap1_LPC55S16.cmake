if(NOT DRIVER_IAP1_LPC55S16_INCLUDED)
    
    set(DRIVER_IAP1_LPC55S16_INCLUDED true CACHE BOOL "driver_iap1 component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_iap.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC55S16)

endif()
