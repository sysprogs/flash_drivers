#include <stm32f7xx_hal.h>
#include "ExtraMemories.h"

#ifdef __cplusplus
extern "C"
#endif
void SysTick_Handler(void)
{
	HAL_IncTick();
	HAL_SYSTICK_IRQHandler();
}
	
QSPI_HandleTypeDef QSPIHandle;
void QSPI_EnableMemoryMappedMode(QSPI_HandleTypeDef *hqspi, uint32_t flashAddress, uint32_t size);

volatile const char QSPI_DATA g_ArrayInQSPI[] = { 1, 2, 3, 4, 5, 6 };
 
int main(void)
{
	HAL_Init();
    
	QSPI_EnableMemoryMappedMode(&QSPIHandle, 0, 0x10000);

    printf("g_ArrayInQSPI contents:\n");
	for (int i = 0; i < sizeof(g_ArrayInQSPI) / sizeof(g_ArrayInQSPI[0]); i++)
	{
    	printf("[%d] = %d\n", i, g_ArrayInQSPI[i]);
	}
}
