if(NOT DRIVER_FLEXCOMM_USART_DMA_LPC55S16_INCLUDED)
    
    set(DRIVER_FLEXCOMM_USART_DMA_LPC55S16_INCLUDED true CACHE BOOL "driver_flexcomm_usart_dma component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_usart_dma.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_flexcomm_LPC55S16)

    include(driver_flexcomm_usart_LPC55S16)

    include(driver_lpc_dma_LPC55S16)

endif()
