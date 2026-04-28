# Configure recipe for CubeMX
inherit cubemx-stm32mp
# Disable CubeMX device tree file check in source as already managed on
# tf-m-stm32mp do_compile tasks
ENABLE_CUBEMX_DTB_CHK = "0"

# Configure device tree file extension
BL2_TYPE:stm32mp2commonmx    = ""
DTS_TYPE_NS:stm32mp2commonmx = ""
DTS_TYPE_S:stm32mp2commonmx  = ""
