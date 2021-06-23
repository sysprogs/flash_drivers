if(NOT DEVICE_LPC54628_CMSIS_LPC54628_INCLUDED)
    
    set(DEVICE_LPC54628_CMSIS_LPC54628_INCLUDED true CACHE BOOL "device_LPC54628_CMSIS component is included.")


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/.
    )

    include(CMSIS_Include_core_cm4_LPC54628)

endif()
