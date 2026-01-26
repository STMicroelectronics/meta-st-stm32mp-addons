# Configure recipe for CubeMX
inherit cubemx-stm32mp

# Init CMAKE_TOOLCHAIN_FILE for CubeMX M33TD application
M33TD_CMAKE_TOOLCHAIN:stm32mpcommonmx = "-DCMAKE_TOOLCHAIN_FILE=${STAGING_EXTDT_DIR}/gcc-arm-none-eabi.cmake"

# Set specific suffix for CubeMX M33TD application
M33TD_FW_TYPE:stm32mpcommonmx = "_CM33_NS"
