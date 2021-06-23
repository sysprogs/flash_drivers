if(NOT DRIVER_SPIFI_DMA_LPC54628_INCLUDED)
    
    set(DRIVER_SPIFI_DMA_LPC54628_INCLUDED true CACHE BOOL "driver_spifi_dma component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_spifi_dma.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_spifi_LPC54628)

    include(driver_lpc_dma_LPC54628)

endif()
