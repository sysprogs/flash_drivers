#include "FLASHPluginConfig.h"
#include <string.h>
#include <stddef.h>
#include "FLASHPluginInterface.h"

/*
    This file implements the interface required by the Sysprogs OpenOCD fork to support programming QSPI FLASH.
    
    To use this plugin, add the following to the additional command-line arguments of your OpenOCD:
        -c "flash bank qspi plugin <base address> 0 0 0 0 path/to/stm32f7disco_qspi.elf"

    The base address is typically 0x90000000.
    Then simply start debugging your QSPI-enabled program and OpenOCD will detect and program the QSPI memory automatically.
*/

#ifdef __cplusplus
extern "C"
#endif
void SysTick_Handler(void)
{
	HAL_IncTick();
	HAL_SYSTICK_IRQHandler();
}


FLASHBankInfo FLASHPlugin_Probe(unsigned base, unsigned size, unsigned width1, unsigned width2)
{
	InterruptEnabler enabler;
    
	FLASHBankInfo result = {
		.BaseAddress = base, 
		.BlockCount = N25Q512A_FLASH_SIZE / N25Q512A_SUBSECTOR_SIZE, 
		.BlockSize = N25Q512A_SUBSECTOR_SIZE,
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
	InterruptEnabler enabler;
    int initialTick = HAL_GetTick();
    int timeout = 5000;
    
	for (unsigned i = 0; i < sectorCount; i++)
	{
    	if ((HAL_GetTick() - initialTick) > timeout)
        	return i;   //OpenOCD will continue the erase operation

    	uint8_t error = BSP_QSPI_Erase_Block((firstSector + i) * N25Q512A_SUBSECTOR_SIZE);
		if (error != QSPI_OK)
			return -1;
	}
	return sectorCount;
}

int FLASHPlugin_Unload()
{
	BSP_QSPI_DeInit();
	HAL_DeInit();
	SysTick->CTRL &= ~SysTick_CTRL_ENABLE_Msk;
    
	for (int i = 0; i < sizeof(NVIC->ICER) / sizeof(NVIC->ICER[0]); i++)
		NVIC->ICER[0] = -1;
    
	return 0;
}

int FLASHPlugin_DoProgramSync(unsigned startOffset, const void *pData, int bytesToWrite)
{
	uint8_t result = BSP_QSPI_Write((uint8_t *)pData, startOffset, bytesToWrite);
	if (result != QSPI_OK)
		return 0;
	return bytesToWrite;
}


int main(void)
{
	extern void *g_pfnVectors;
    
	SCB->VTOR = (uint32_t)&g_pfnVectors;
	HAL_Init();
	BSP_QSPI_Init();
	FLASHPlugin_InitDone();
    
#ifdef DEBUG
    TestFLASHProgramming(0x90000000, 0);
#endif

	for (;;)
		;
}
