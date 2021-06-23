/*
 * Copyright (c) 2016, Freescale Semiconductor, Inc.
 * Copyright 2016-2017 NXP
 * All rights reserved.
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "pin_mux.h"
#include "board.h"
#include "fsl_flashiap.h"
#include "fsl_common.h"

#include <FLASHPluginInterface.h>
#include <FLASHPluginConfig.h>

void error_trap(void)
{
    asm("bkpt 255");
}

FLASHBankInfo FLASHPlugin_Probe(unsigned base, unsigned size, unsigned width1, unsigned width2)
{
	FLASHBankInfo result = {
		.BaseAddress = base, 
		.BlockCount = FSL_FEATURE_SYSCON_FLASH_SIZE_BYTES / FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES,
		.BlockSize = FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES,
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
	status_t status = FLASHIAP_PrepareSectorForWrite(firstSector, firstSector + sectorCount - 1);
	if (status != kStatus_Success)
		error_trap();

	status = FLASHIAP_EraseSector(firstSector, firstSector + sectorCount - 1, SystemCoreClock);
	if (status != kStatus_Success)
		error_trap();

	return sectorCount;
}

int FLASHPlugin_Unload()
{
	return 0;
}

static char __attribute__((aligned(FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES))) s_PageBuffer[FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES];

int FLASHPlugin_DoProgramSync(unsigned startOffset, const void *pData, int bytesToWrite)
{
	int sectors = bytesToWrite / FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES;
	int i;
	for (i = 0; i < sectors; i++)
	{
		memcpy(s_PageBuffer, ((char *)pData + i  * FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES), FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES);
		
		unsigned offsetInFLASH = startOffset + i  * FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES;
		if (offsetInFLASH == 0)
		{
			//The IAP interface will refuse to write first page of the ROM unless the contents look like a 'valid' image.
			//The criteria for a 'valid' image are described in section 5.3.5 of UM10912 (rev. 2.4).
			//Specifically, the sum of the first 8 vectors in an image must be 0. 
			//We patch the image on-the-fly in order to make sure it is accepted by the IAP.
			uint32_t *pVectors = (uint32_t *)s_PageBuffer;
			uint32_t sum = 0;
			for (int j = 0; j < 7; j++)
				sum += pVectors[j];
			
			pVectors[7] = 0 - sum;			
		}
		
		status_t status = FLASHIAP_PrepareSectorForWrite(offsetInFLASH / FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES, offsetInFLASH / FSL_FEATURE_SYSCON_FLASH_SECTOR_SIZE_BYTES);
		if (status != kStatus_Success)
			break;

		status = FLASHIAP_CopyRamToFlash(offsetInFLASH,
			(uint32_t *)s_PageBuffer,
			FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES,
			SystemCoreClock);
		
		if (status != kStatus_Success)
			break;
	}
	
	if (!i)
		return -1;
	
	return i * FSL_FEATURE_SYSCON_FLASH_PAGE_SIZE_BYTES;
}


int main(void)
{
	BOARD_BootClockFROHF48M();
	FLASHPlugin_InitDone();
    
#ifdef DEBUG
	TestFLASHProgramming(0, 0);
#endif

}
