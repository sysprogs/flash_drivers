#pragma once
#include <stdint.h>

struct FLASHParameters
{
	uint32_t BlockBase, SectorSize, TotalSize, PageSize;
};

extern struct FLASHParameters g_FLASHParameters;
#define MINIMUM_PROGRAMMED_BLOCK_SIZE g_FLASHParameters.PageSize
#define FLASH_PLUGIN_SUPPORT_ASYNC_PROGRAMMING 1