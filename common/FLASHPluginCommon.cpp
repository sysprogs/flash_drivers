#include "FLASHPluginInterface.h"
#include "FLASHPluginConfig.h"

#ifndef MINIMUM_PROGRAMMED_BLOCK_SIZE
#error Please define MINIMUM_PROGRAMMED_BLOCK_SIZE in your FLASHPluginConfig.h
#endif

struct plugin_timeouts
{
    unsigned erase;
    unsigned write;
    unsigned init;
    unsigned load;
    unsigned protect;
};

struct image_plugin_timeouts
{
    unsigned size;
    struct plugin_timeouts timeouts;
};


//If you want to override default time-out values for the plugin, provide another definition of FLASHPlugin_TimeoutTable in your plugin sources.
extern "C" 
{
    __attribute__((weak)) image_plugin_timeouts FLASHPlugin_TimeoutTable = 
    { 
        .size = sizeof(struct plugin_timeouts),
        .timeouts =
        { 
            .erase = 60000,
            .write = 1000,
            .init = 1000,
            .load = 10000,
            .protect = 1000,
        }
    };
}

volatile void * __attribute__((used)) g_FunctionTable[] = { 
    (void *)&FLASHPlugin_Unload,
    (void *)&FLASHPlugin_Probe,
    (void *)&FLASHPlugin_FindWorkArea,
    (void *)&FLASHPlugin_EraseSectors,
    (void *)&FLASHPlugin_ProgramAsync,
    
    (void *)&FLASHPlugin_ProtectSectors,
    (void *)&FLASHPlugin_CheckSectorProtection,
};

void FLASHPlugin_InitDone()
{
    asm("cpsid i");
    g_FunctionTable[0] = (void *)&FLASHPlugin_TimeoutTable;
}

int FLASHPlugin_NotImplemented()
{
    return -1;
}

int FLASHPlugin_CheckSectorProtection(unsigned firstSector, unsigned sectorCount, unsigned char *pBuffer) __attribute__((weak, alias("FLASHPlugin_NotImplemented")));
int FLASHPlugin_ProtectSectors(unsigned protect, unsigned firstSector, unsigned sectorCount)__attribute__((weak, alias("FLASHPlugin_NotImplemented")));

#if FLASH_PLUGIN_SUPPORT_ASYNC_PROGRAMMING
int FLASHPlugin_ProgramAsync(unsigned startOffset, FIFOHeader *pData, const void *pEndOfData, unsigned bytesToWrite)
{
    InterruptEnabler enabler;
    unsigned done = 0;
    unsigned bufferSize = (char *)pEndOfData - (char *)(pData + 1);
    if (bufferSize % MINIMUM_PROGRAMMED_BLOCK_SIZE)
    {
        pData->ReadPointer = 0;
        return -4;
    }
    unsigned maxBytesAtOnce = ((bufferSize / MINIMUM_PROGRAMMED_BLOCK_SIZE) / 4) * MINIMUM_PROGRAMMED_BLOCK_SIZE;
    if (maxBytesAtOnce == 0)
        maxBytesAtOnce = bufferSize;
    
    while (done < bytesToWrite)
    {
        char *rp = pData->ReadPointer;
        char *wp = pData->WritePointer;
        if (wp == rp)
            continue;
        
        if (wp < rp)
            wp = (char *)pEndOfData;
        if (wp > pEndOfData)
        {
            pData->ReadPointer = 0;
            return -1;
        }
        
        unsigned todo = wp - rp;
        if (!todo)
            continue;
        
        if (todo % MINIMUM_PROGRAMMED_BLOCK_SIZE)
        {
            if ((done + todo) != bytesToWrite)
            {
                pData->ReadPointer = 0;
                return -2;  //Data should be fed in multiples of MINIMUM_PROGRAMMED_BLOCK_SIZE except for the last block, otherwise the underlying algorithm won't be able to handle it
            }
            int padding = MINIMUM_PROGRAMMED_BLOCK_SIZE - todo % MINIMUM_PROGRAMMED_BLOCK_SIZE;
            for (int i = 0; i < padding; i++)
                rp[todo++] = 0xFF;  //Pad last page with 0xFFs
        }
        else
        {
            if (todo > maxBytesAtOnce)
                todo = maxBytesAtOnce;
        }
        
        int done_now = FLASHPlugin_DoProgramSync(startOffset + done, rp, todo);
        if (done_now != todo)
        {
            pData->ReadPointer = 0;
            return -3;
        }

        rp += todo;
        while (rp >= pEndOfData)
            rp -= bufferSize;        
        
        pData->ReadPointer = rp;

        done += todo;
    }

    return done;
}
#endif


#include <string.h>
#include <alloca.h>
#include <algorithm>

void TestFLASHProgramming(unsigned base, unsigned size)
{
    FLASHBankInfo info = FLASHPlugin_Probe(base, size, 0, 0);
    
    unsigned result = FLASHPlugin_EraseSectors(0, std::min(400, (int)info.BlockCount));
    if (result <= 0)
        asm("bkpt 255");
    
    FIFOHeader *pHeader = (FIFOHeader *)alloca(sizeof(FIFOHeader) + info.WriteBlockSize * 2);
    pHeader->WritePointer = pHeader->ReadPointer = (char *)(pHeader + 1);
	memset(pHeader + 1, 0x55, info.WriteBlockSize);
	pHeader->WritePointer += info.WriteBlockSize;
        
    //Normally OpenOCD will launch this method and then start updating pHeader->WritePointer while the method is running.
    //This test function pre-initializes WritePointer to indicate that exactly one block has been written to the buffer
    //so that the FLASHPlugin_ProgramAsync() will succeed without any further modifications.
    result = FLASHPlugin_ProgramAsync(0, pHeader, (char *)(pHeader + 1) + info.WriteBlockSize * 2, info.WriteBlockSize);
	if (result != info.WriteBlockSize)
        asm("bkpt 255");
    
    //After FLASHPlugin_ProgramAsync() data, it should set the ReadPointer at the end of the consumed block.
    if(pHeader->ReadPointer != pHeader->WritePointer)
        asm("bkpt 255");
}