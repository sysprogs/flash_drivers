if(NOT DRIVER_EMC_LPC54628_INCLUDED)
    
    set(DRIVER_EMC_LPC54628_INCLUDED true CACHE BOOL "driver_emc component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_emc.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC54628)

endif()
