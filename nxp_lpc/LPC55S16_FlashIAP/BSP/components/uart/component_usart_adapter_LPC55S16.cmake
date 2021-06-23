if(NOT COMPONENT_USART_ADAPTER_LPC55S16_INCLUDED)
    
    set(COMPONENT_USART_ADAPTER_LPC55S16_INCLUDED true CACHE BOOL "component_usart_adapter component is included.")

    target_sources(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/fsl_adapter_usart.c
    )


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )


    include(driver_common_LPC55S16)

    include(driver_flexcomm_usart_LPC55S16)

    include(driver_flexcomm_LPC55S16)

endif()
