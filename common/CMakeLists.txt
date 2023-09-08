add_library(FLASHPlugin INTERFACE FLASHPluginCommon.cpp)

target_sources(FLASHPlugin INTERFACE 
	FLASHPluginCommon.cpp)

target_include_directories(FLASHPlugin INTERFACE .)
