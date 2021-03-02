#pragma once

/*
    The Sysprogs fork of OpenOCD uses an ELF file providing the functions below to automaticaly program external FLASH memories.
    The usual use scenario is shown below:
        1. OpenOCD makes a backup of the RAM area needed by the image and loads the image
        2. OpenOCD calls the entry point and waits until the image calls FLASHPlugin_InitDone()
        3. OpenOCD calls FLASHPlugin_Probe() and FLASHPlugin_FindWorkArea() to query general information about the FLASH bank
        4. OpenOCD calls FLASHPlugin_Unload() and then restores the RAM area occupied by the image and the work area.
        
    When gdb requests OpenOCD to write the FLASH memory, the following happens:
        1. The plugin is loaded into the target again
        2. OpenOCD calls FLASHPlugin_EraseSectors()
        3. OpenOCD calls FLASHPlugin_ProgramAsync(). If it's not implemented, it calls FLASHPlugin_ProgramSync() several times instead.
        
    The FLASH plugin should be linked using the RAM version of the linker script for your device. OpenOCD will then automatically load
    the plugin into RAM, let it do the programming and restore the original RAM contents.
*/

//General information about the FLASH bank. Queried during initialization.
struct FLASHBankInfo
{
    //Address of the FLASH bank in the memory space
    unsigned BaseAddress;
    
    //Amount of independently erased blocks
    unsigned BlockCount;
    
    //Size of each block
    unsigned BlockSize;
    
    //Size of smallest independently writable block. All write operations will be rounded up to the
    //multiple of this value. If your FLASH does not have such a limiation, simply set it to 1.
    unsigned WriteBlockSize;
};

//Information about the temporary memory region used to transfer data between PC and the plugin.
//OpenOCD will automatically backup and restore it.
struct WorkAreaInfo
{
    void *Address;
    unsigned Size;
};

//Control structure used control data flow to FLASHPlugin_ProgramAsync()
struct FIFOHeader
{
    char * volatile WritePointer;
    char * volatile ReadPointer;
};

#ifdef __cplusplus
class InterruptEnabler
{
public:
    InterruptEnabler()
    {
        asm("cpsie i");
    }
    
    ~InterruptEnabler()
    {
        asm("cpsid i");
    }
};
#endif

#ifdef __cplusplus
extern "C"
{
#endif
    //This function checks the FLASH bank and returns the general information about it. The base, size, chipWidth and busWidth arguments come from the
    //arguments to the 'flash bank' command in OpenOCD and can be ignored or used to compute the FLASH parameters depending on the implementation.
    struct FLASHBankInfo FLASHPlugin_Probe(unsigned base, unsigned size, unsigned chipWidth, unsigned busWidth);
    
    //This function is called by OpenOCD to locate the region of RAM that will be used to transfer data between the PC and the plugin.
    //endOfStack points to the end of the stack area allocated by OpenOCD directly beyond the bounds of the image. It is not equal to the usual _estack that points to
    //the end of RAM. If the FLASH plugin is designed to run on several different devices with different RAM sizes, it can detect the end of RAM in this function and return
    //the area between the endOfStack and end of RAM as the work area.
    struct WorkAreaInfo FLASHPlugin_FindWorkArea(void *endOfStack);
    
    //This function simply erases 'sectorCount' sectors starting from 'firstSector'. It should return the amount of sectors successfully erased or a negative value to indicate an error.
    int FLASHPlugin_EraseSectors(unsigned firstSector, unsigned sectorCount);    
    
    //This function is called when the plugin is to be unloaded. It should revert any changes to hardware made during initialization (e.g. disable previousl yenabled interrupts).
    //Note that OpenOCD will automatically backup/restore all memory occupied by the plugin image's sections, so the plugin can use global/static variables to record the previous hardware state.
    int FLASHPlugin_Unload(); 
    
    //This optional function should program a block of memory at a given offset. 'startOffset' specifies offset in bytes from the beginning of the FLASH bank. 
    //The function should return 0 on success, error code on failure.
    //WARNING: Only implement this function if you encounter problems with FLASHPlugin_ProgramAsync().
    int FLASHPlugin_ProgramSync(unsigned startOffset,const void *pData, unsigned bytesToWrite);
    
    //This function performs asynchronous programming. OpenOCD will modify the WritePointer field of 'pData' each time it writes new data to the buffer and will expect the function to
    //update the ReadPointer field each time it reads a chunk of data. The WritePointer/ReadPointer will only be updated in multiples of WriteBlockSize returned in FLASHPlugin_Probe().
    //The FLASH plugin framework provides a default implementation of this method in FLASHPluginCommon.cpp that calls FLASHPlugin_DoProgramSync() to perform the actual programming.
    int FLASHPlugin_ProgramAsync(unsigned startOffset, struct FIFOHeader *pData, const void *pEndOfData, unsigned bytesToWrite);
    
    //This function should be called by the plugin once it completes initialization. The contents of the function is arbitrary. OpenOCD will set a breakpoint in this function to detect
    //when the initialization completes. Once the breakpoint triggers, OpenOCD will intercept the program flow and call various FLASHPlugin() functions.
    void __attribute__((noinline)) FLASHPlugin_InitDone();
    
    //Non-implemented optional methods will be automatically defined as references to this method. 
    //OpenOCD will detect this and understand that the methods are not implemented.
    int __attribute__((noinline)) FLASHPlugin_NotImplemented();
    
    //Optional functions
    int FLASHPlugin_CheckSectorProtection(unsigned firstSector, unsigned sectorCount, unsigned char *pBuffer);
    int FLASHPlugin_ProtectSectors(unsigned protect, unsigned firstSector, unsigned sectorCount);
    
    //This function is called by FLASHPlugin_ProgramAsync() to perform the actual programming. It should return the amount of bytes successfully programmed or a negative value to indicate an error.
    //The bytesToWrite will always be a multiple of WriteBlockSize except for the last block.
    int FLASHPlugin_DoProgramSync(unsigned startOffset, const void *pData, int bytesToWrite);    
#ifdef __cplusplus
}
#endif

//Test interface
#ifdef __cplusplus
extern "C"
{
#endif
    //This function will try programming fixed values into the FLASH memory using the interface functions as if OpenOCD was calling them.
    //Step through it in the debugger to test out your FLASH driver. It is NOT a part of the API called by OpenOCD.
    void TestFLASHProgramming(unsigned base, unsigned size);
#ifdef __cplusplus
}
#endif
