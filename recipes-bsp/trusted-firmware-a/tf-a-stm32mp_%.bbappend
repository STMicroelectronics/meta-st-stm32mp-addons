# Configure recipe for CubeMX
inherit cubemx-stm32mp

CUBEMX_DTB_PATH_TFA ?= "tf-a"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_TFA}"

CUBEMX_DTB_SRC_PATH ?= "fdts"
