if(NOT DRIVER_FLEXCOMM_SPI_DMA_LPC54628_INCLUDED)
    
    set(DRIVER_FLEXCOMM_SPI_DMA_LPC54628_INCLUDED true CACHE BOOL "driver_flexcomm_spi_dma component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_spi_dma.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_flexcomm_LPC54628)

    include(driver_flexcomm_spi_LPC54628)

    include(driver_lpc_dma_LPC54628)

endif()
