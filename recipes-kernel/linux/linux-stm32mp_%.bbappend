# Configure recipe for CubeMX
inherit cubemx-stm32mp

CUBEMX_DTB_PATH_LINUX ?= "kernel"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_LINUX}"

CUBEMX_DTB_SRC_PATH ?= "arch/arm/boot/dts"
