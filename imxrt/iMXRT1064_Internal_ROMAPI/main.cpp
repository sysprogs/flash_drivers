/*
 * Copyright 2020 NXP
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */
#include "fsl_romapi.h"
#include "fsl_cache.h"

#include "pin_mux.h"
#include "clock_config.h"
#include "board.h"
#include "fsl_common.h"
#include <FLASHPluginInterface.h>
#include <FLASHPluginConfig.h>

/*******************************************************************************
 * Prototypes
 ******************************************************************************/
void error_trap(void);
void app_finalize(void);
status_t FLEXSPI_NorFlash_GetVendorID(uint32_t instance, uint32_t *vendorID);

/*******************************************************************************
 * Variables
 ******************************************************************************/

/*! @brief FLEXSPI NOR flash driver Structure */
static flexspi_nor_config_t norConfig;

void error_trap(void)
{
	asm("bkpt 255");
}


status_t FLEXSPI_NorFlash_GetVendorID(uint32_t instance, uint32_t *vendorID)
{
    uint32_t lut_seq[4];
    memset(lut_seq, 0, sizeof(lut_seq));
    // Read manufacturer ID
    lut_seq[0] = FSL_ROM_FLEXSPI_LUT_SEQ(CMD_SDR, FLEXSPI_1PAD, 0x9F, READ_SDR, FLEXSPI_1PAD, 4);
    ROM_FLEXSPI_NorFlash_UpdateLut(instance, NOR_CMD_LUT_SEQ_IDX_READID, (const uint32_t *)lut_seq, 1U);

    flexspi_xfer_t xfer;
    xfer.operation            = kFLEXSPIOperation_Read;
    xfer.seqId                = NOR_CMD_LUT_SEQ_IDX_READID;
    xfer.seqNum               = 1U;
    xfer.baseAddress          = 0U;
    xfer.isParallelModeEnable = false;
    xfer.rxBuffer             = vendorID;
    xfer.rxSize               = 1U;

    uint32_t status = ROM_FLEXSPI_NorFlash_CommandXfer(instance, &xfer);
    if (*vendorID != kSerialFlash_Winbond_ManufacturerID)
    {
        status = kStatus_ROM_FLEXSPINOR_Flash_NotFound;
        return status;
    }

    return status;
}

FLASHBankInfo FLASHPlugin_Probe(unsigned base, unsigned size, unsigned width1, unsigned width2)
{
	FLASHBankInfo result = {
		.BaseAddress = base, 
		.BlockCount = norConfig.memConfig.sflashA1Size /  norConfig.sectorSize,
		.BlockSize = norConfig.sectorSize,
		.WriteBlockSize = MINIMUM_PROGRAMMED_BLOCK_SIZE
	};
	
	if (norConfig.pageSize != MINIMUM_PROGRAMMED_BLOCK_SIZE)
		error_trap();
	
	return result;
}

WorkAreaInfo FLASHPlugin_FindWorkArea(void *endOfStack)
{
	InterruptEnabler enabler;
    
	WorkAreaInfo info = { .Address = endOfStack, .Size = 4096 };
	return info;
}

int FLASHPlugin_EraseSectors(unsigned firstSector, unsigned sectorCount)
{
	status_t status = ROM_FLEXSPI_NorFlash_Erase(FlexSpiInstance, &norConfig, firstSector * norConfig.sectorSize, sectorCount * norConfig.sectorSize);
	if (status != kStatus_Success)
		error_trap();

	return sectorCount;
}

int FLASHPlugin_Unload()
{
	return 0;
}

int FLASHPlugin_DoProgramSync(unsigned startOffset, const void *pData, int bytesToWrite)
{
	int pages = bytesToWrite / FLASH_PAGE_SIZE;
	for (int i = 0; i < pages; i++)
	{
		status_t status = ROM_FLEXSPI_NorFlash_ProgramPage(FlexSpiInstance,
			&norConfig,
			startOffset + i * FLASH_PAGE_SIZE,
			(const uint32_t *)((const char *)pData + i  * FLASH_PAGE_SIZE));
		
		if (status != kStatus_Success)
			return i * FLASH_PAGE_SIZE;
	}
	
	return pages * FLASH_PAGE_SIZE;
}

int main(void)
{
    //BOARD_ConfigMPU();
    BOARD_InitPins();
    //BOARD_BootClockRUN();

    serial_nor_config_option_t option;
    memset(&option, 0U, sizeof(option));
    option.option0.U = 0xc0000007U;

    memset(&norConfig, 0U, sizeof(flexspi_nor_config_t));

    /* Disable I cache */
    SCB_DisableICache();

    /* Setup FLEXSPI NOR Configuration Block */
    status_t status = ROM_FLEXSPI_NorFlash_GetConfig(FlexSpiInstance, &norConfig, &option);
	if (status != kStatus_Success)
		error_trap();

    /* Initializes the FLEXSPI module for the other FLEXSPI APIs */
    status = ROM_FLEXSPI_NorFlash_Init(FlexSpiInstance, &norConfig);
    if (status != kStatus_Success)
		error_trap();

    /* Perform software reset after initializing flexspi module */
    ROM_FLEXSPI_NorFlash_ClearCache(FlexSpiInstance);

    //status = FLEXSPI_NorFlash_GetVendorID(FlexSpiInstance, &vendorID);

    FLASHPlugin_InitDone();

#ifdef DEBUG
	TestFLASHProgramming(0x70000000, 0);
	asm("bkpt 255");    //Self-test passed
#endif
	
    return 0;
}
