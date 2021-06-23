if(NOT DRIVER_FRO_CALIB_LPC54628_INCLUDED)
    
    set(DRIVER_FRO_CALIB_LPC54628_INCLUDED true CACHE BOOL "driver_fro_calib component is included.")


    target_include_directories(${MCUX_SDK_PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/drivers
    )

    include(driver_common_LPC54628)

endif()
