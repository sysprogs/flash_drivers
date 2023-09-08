#include <stm32f7xx_hal.h>
#include <stm32_hal_legacy.h>
#include <ExtraMemories.h>

extern "C" void QSPI_TEXT FunctionInQSPIFLASH();

#ifdef __cplusplus
extern "C"
#endif
void SysTick_Handler(void)
{
	HAL_IncTick();
	HAL_SYSTICK_IRQHandler();
}

static const int QSPI_DATA LargeArray[] = { 100, 200, 300, 400, 500, 600 };
void QSPI_TEXT FunctionInQSPIFLASH()
{
	__GPIOC_CLK_ENABLE();
	GPIO_InitTypeDef GPIO_InitStructure;

	GPIO_InitStructure.Pin = GPIO_PIN_12;

	GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStructure.Speed = GPIO_SPEED_FREQ_HIGH;
	GPIO_InitStructure.Pull = GPIO_NOPULL;
	HAL_GPIO_Init(GPIOC, &GPIO_InitStructure);

	for (int i = 0;;i++)
	{
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_12, GPIO_PIN_SET);
		HAL_Delay(LargeArray[i % (sizeof(LargeArray) / sizeof(LargeArray[0]))]);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_12, GPIO_PIN_RESET);
    	HAL_Delay(LargeArray[i % (sizeof(LargeArray) / sizeof(LargeArray[0]))]);
    }
}

void QSPI_EnableMemoryMappedMode(QSPI_HandleTypeDef *hqspi, uint32_t flashAddress, uint32_t size);
QSPI_HandleTypeDef QSPIHandle;

int main(void)
{
    HAL_Init();
    QSPI_EnableMemoryMappedMode(&QSPIHandle, 0, 0x10000);
    FunctionInQSPIFLASH();
}