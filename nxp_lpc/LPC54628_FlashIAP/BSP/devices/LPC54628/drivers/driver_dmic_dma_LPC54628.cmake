if(NOT DRIVER_DMIC_DMA_LPC54628_INCLUDED)
    
    set(DRIVER_DMIC_DMA_LPC54628_INCLUDED true CACHE BOOL "driver_dmic_dma component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_dmic_dma.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_dmic_LPC54628)

    include(driver_lpc_dma_LPC54628)

endif()
