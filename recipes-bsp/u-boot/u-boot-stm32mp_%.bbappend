# Configure recipe for CubeMX
inherit cubemx-stm32mp

CUBEMX_DTB_PATH_UBOOT ?= "u-boot"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_UBOOT}"

CUBEMX_DTB_SRC_PATH ?= "arch/arm/dts"
