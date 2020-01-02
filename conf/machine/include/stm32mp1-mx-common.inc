# Common parameters for all mx machines
# =========================================================================
# Chip architecture
# =========================================================================
DEFAULTTUNE = "cortexa7thf-neon-vfpv4"
include conf/machine/include/tune-cortexa7.inc

# Define specific common machine name
MACHINEOVERRIDES .= ":stm32mpcommonmx"

# Mandatory to define these variables as they are used for extlinux part
CUBEMX_DTB ?= ""
CUBEMX_DTB_PATH ?= "${STM32MP_MX_BASE}/mx/${CUBEMX_PROJECT}"

# Configure devicetree file name to use
CUBEMX_DTB_SET = "${@'${CUBEMX_DTB}' if d.getVar('CUBEMX_PROJECT') else '${CUBEMX_BOARD_REFERENCE}'}"

# Define list of devicetree per board
CUBEMX_DISCO = "${@bb.utils.contains_any('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-dk2 stm32mp157a-dk1', '1', '0', d)}"
STM32MP_DT_FILES_EV += "${@'' if ${CUBEMX_DISCO} else '${CUBEMX_DTB_SET}'}"
STM32MP_DT_FILES_DK += "${@'${CUBEMX_DTB_SET}' if ${CUBEMX_DISCO} else ''}"

# =========================================================================
# Machine features
# =========================================================================
# Bluetooth, wifi only available on DISCO DK2 boards
MACHINE_FEATURES += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-dk2', 'bluetooth', '', d)}"
MACHINE_FEATURES += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-dk2', 'wifi', '', d)}"
MACHINE_FEATURES += "${@'gpu' if d.getVar('ACCEPT_EULA_'+d.getVar('MACHINE')) == '1' else ''}"
# Splashscreen enabled
MACHINE_FEATURES += "splashscreen"

# =========================================================================
# Image
# =========================================================================
# Add ubi FSTYPES to default ones for nand volumes
IMAGE_FSTYPES += "${@bb.utils.contains_any('BOOTDEVICE_LABELS', 'nand-4-256 nor-nand-4-256', 'stmultiubi', '', d)}"

# =========================================================================
# Kernel
# =========================================================================
# Kernel config
# Set this address to 0xC2000040, which is 0xC2000000 + 0x40.
# 0xC2000000 is the memory address where U-Boot will copy from flash the file uImage and 0x40 is uImage header size (64Bytes).
# With this value, U-Boot will be able to execute in place the zImage contained in uImage.
ST_KERNEL_LOADADDR   = "0xC2000040"

# For eval board: auto-load goodix module (touchscreen module)
KERNEL_MODULE_AUTOLOAD = "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-ev1', 'goodix', '', d)}"

# Kernel device tree: make sure to always have the default eval board device tree
STM32MP_KERNEL_DEVICETREE_append = " ${CUBEMX_BOARD_REFERENCE}.dtb "

# Define the devicetree for Linux A7 examples
#LINUX_A7_EXAMPLES_DT += "${CUBEMX_BOARD_REFERENCE}-m4-examples"
#Should be replaced later by the line upper if we have specificity for DK1
LINUX_A7_EXAMPLES_DT += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-ev1', 'stm32mp157c-ev1-a7-examples', '', d)}"
LINUX_A7_EXAMPLES_DT += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-dk2', 'stm32mp157c-dk2-a7-examples', '', d)}"

# =========================================================================
# M4 copro
# =========================================================================
# Define the devicetree for M4 example
#CUBE_M4_EXAMPLES_DT += "${CUBEMX_BOARD_REFERENCE}-m4-examples"
#Should be replaced later by the line upper if we have specificity for DK1
CUBE_M4_EXAMPLES_DT += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-ev1', 'stm32mp157c-ev1-m4-examples', '', d)}"
CUBE_M4_EXAMPLES_DT += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-dk2', 'stm32mp157c-dk2-m4-examples', '', d)}"

# Define specific board reference to use
#M4_BOARDS = "STM32MP157C-EV1"
#M4_BOARDS = "${@d.getVar('CUBEMX_BOARD_REFERENCE').upper()}"
#Should be replaced later by the line upper if we have specificity for DK1
#For the moment we are using same examples for dk1 and dk2
M4_BOARDS += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-ev1', 'STM32MP157C-EV1', '', d)}"
M4_BOARDS += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157a-dk1', 'STM32MP157C-DK2', '', d)}"
M4_BOARDS += "${@bb.utils.contains('CUBEMX_BOARD_REFERENCE', 'stm32mp157c-dk2', 'STM32MP157C-DK2', '', d)}"
