cmake_minimum_required(VERSION 3.15)
project (nxp)

include ("${CMAKE_CURRENT_SOURCE_DIR}/visualgdb/root.cmake")

add_subdirectory(LPC54628_FlashIAP)
add_subdirectory(LPC55S16_FlashIAP)
