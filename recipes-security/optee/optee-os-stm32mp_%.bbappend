# Configure recipe for CubeMX
inherit cubemx-stm32mp

CUBEMX_DTB_PATH_OPTEEOS ?= "optee-os"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_OPTEEOS}"

CUBEMX_DTB_SRC_PATH ?= "core/arch/arm/dts"
