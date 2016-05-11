#pragma once

//E.g. void QSPI_TEXT func();
#define QSPI_TEXT __attribute__((section(".qspi_text")))

//E.g. int QSPI_DATA g_Initialized = 1;
#define QSPI_DATA __attribute__((section(".qspi_data")))

//E.g. int QSPI_BSS g_Uninitialized;
#define QSPI_BSS __attribute__((section(".qspi_bss")))


