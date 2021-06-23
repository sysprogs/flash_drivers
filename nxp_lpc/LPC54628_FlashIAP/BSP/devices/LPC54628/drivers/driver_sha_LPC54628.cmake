if(NOT DRIVER_SHA_LPC54628_INCLUDED)
    
    set(DRIVER_SHA_LPC54628_INCLUDED true CACHE BOOL "driver_sha component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_sha.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC54628)

endif()
