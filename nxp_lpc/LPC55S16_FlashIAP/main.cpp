/*
 * Copyright 2018 NXP
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "pin_mux.h"
#include "board.h"
#include "fsl_iap.h"
#include "fsl_iap_ffr.h"
#include "fsl_common.h"
#include "fsl_power.h"

#include <FLASHPluginInterface.h>
#include <FLASHPluginConfig.h>

void error_trap(void)
{
	asm("bkpt 255");
}

static flash_config_t s_FLASHInstance;
struct FLASHParameters g_FLASHParameters;

FLASHBankInfo FLASHPlugin_Probe(unsigned base, unsigned size, unsigned width1, unsigned width2)
{
	FLASHBankInfo result = {
		.BaseAddress = base, 
		.BlockCount = g_FLASHParameters.TotalSize / g_FLASHParameters.SectorSize,
		.BlockSize = g_FLASHParameters.SectorSize,
		.WriteBlockSize = MINIMUM_PROGRAMMED_BLOCK_SIZE
	};
	
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
	status_t status = FLASH_Erase(&s_FLASHInstance,
		firstSector * g_FLASHParameters.SectorSize,
		sectorCount * g_FLASHParameters.SectorSize,
		kFLASH_ApiEraseKey);
	
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
	status_t status = FLASH_Program(&s_FLASHInstance, startOffset, (uint8_t *)pData, bytesToWrite);
	if (status != kStatus_Success)
		error_trap();

	return bytesToWrite;
}

int main()
{
	POWER_SetBodVbatLevel(kPOWER_BodVbatLevel1650mv, kPOWER_BodHystLevel50mv, false);
	BOARD_BootClockFROHF96M();

	if (FLASH_Init(&s_FLASHInstance) != kStatus_Success)
    {
        error_trap();
    }
	
	FLASH_GetProperty(&s_FLASHInstance, kFLASH_PropertyPflashBlockBaseAddr, &g_FLASHParameters.BlockBase);
	FLASH_GetProperty(&s_FLASHInstance, kFLASH_PropertyPflashSectorSize, &g_FLASHParameters.SectorSize);
	FLASH_GetProperty(&s_FLASHInstance, kFLASH_PropertyPflashTotalSize, &g_FLASHParameters.TotalSize);
	FLASH_GetProperty(&s_FLASHInstance, kFLASH_PropertyPflashPageSize, &g_FLASHParameters.PageSize);

	FLASHPlugin_InitDone();
    
#ifdef DEBUG
	TestFLASHProgramming(0x00000000, 0);
#endif

	asm("bkpt 255");
	return 0;
}
