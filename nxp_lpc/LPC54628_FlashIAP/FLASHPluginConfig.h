#pragma once
#include <stdint.h>
#include <fsl_device_registers.h>

#define MINIMUM_PROGRAMMED_BLOCK_SIZE FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES
#define FLASH_PLUGIN_SUPPORT_ASYNC_PROGRAMMING 1