#
# Internal Test Config
#

# Boot Scheme
# =========================================================================
# DISCO / EVAL : basic, trusted or optee
# =========================================================================
BOOTSCHEME_LABELS ?= "trusted"

# Boot Device Choice
# =========================================================================
# DISCO : sdcard
# EVAL  : sdcard, emmc, nand-4-256, nor-sdcard, nor-emmc or nor-nand-4-256
# =========================================================================
# Define the config labels to use to generate flashlayout file
BOOTDEVICE_LABELS ?= "sdcard"

# Configs below only available with EVAL board
#BOOTDEVICE_LABELS ?= "emmc"
#BOOTDEVICE_LABELS ?= "nand-4-256"
#BOOTDEVICE_LABELS ?= "nor-emmc"
#BOOTDEVICE_LABELS ?= "nor-nand-4-256"
#BOOTDEVICE_LABELS ?= "nor-sdcard"

# Board Type Choice
# =========================================================================
# DISCO : stm32mp157a-dk1 or stm32mp157c-dk2
# EVAL  : stm32mp157c-ev1
# =========================================================================
# Define the board reference devicetree name
# WARNING: only one setting allowed
#CUBEMX_BOARD_REFERENCE ?= "stm32mp157a-dk1"
#CUBEMX_BOARD_REFERENCE ?= "stm32mp157c-dk2"
CUBEMX_BOARD_REFERENCE ?= "stm32mp157c-ev1"

# CubeMX Project Config
# =========================================================================
# Assign CubeMX Board devicetree and project path name
#CUBEMX_DTB = "stm32mp157c-defaultmxconfig-mx"
#CUBEMX_PROJECT = "STM32MP157C-DK2/DefaultMXConfig/DeviceTree/DefaultMXConfig"
#CUBEMX_PROJECT = "STM32MP157C-EV1/DefaultMXConfig/DeviceTree/DefaultMXConfig"
