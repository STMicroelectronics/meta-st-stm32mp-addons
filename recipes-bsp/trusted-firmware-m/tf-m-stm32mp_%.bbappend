# Configure recipe for CubeMX
inherit cubemx-stm32mp
# Disable CubeMX device tree file check in source as already managed on
# tf-m-stm32mp do_compile tasks
ENABLE_CUBEMX_DTB_CHK = "0"
