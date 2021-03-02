#pragma once

#define FlexSpiInstance           1U
#define EXAMPLE_FLEXSPI_AMBA_BASE FlexSPI2_AMBA_BASE
#define FLASH_SIZE                0x400000UL /* 4MBytes */
#define FLASH_PAGE_SIZE           256UL      /* 256Bytes */
#define FLASH_SECTOR_SIZE         0x1000UL   /* 4KBytes */
#define FLASH_BLOCK_SIZE          0x10000UL  /* 64KBytes */

#define MINIMUM_PROGRAMMED_BLOCK_SIZE FLASH_PAGE_SIZE
#define FLASH_PLUGIN_SUPPORT_ASYNC_PROGRAMMING 1