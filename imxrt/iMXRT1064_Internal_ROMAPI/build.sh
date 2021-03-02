mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=DEBUG -DTOOLCHAIN_ROOT=/usr/bin -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DPLATFORM=VisualGDB
make