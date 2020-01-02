# =========================================================================
# EXTLINUX is dynamic according to FLASHLAYOUT CONFIG set
# =========================================================================

# -----------------------------------------------------------------------------
# CubeMX configuration
# -----------------------------------------------------------------------------
# Define targets to use: configure only CubeMX machine to add CubeMX label(s) only
UBOOT_EXTLINUX_TARGETS_emmc         = "targetcubemx_emmc"
UBOOT_EXTLINUX_TARGETS_emmc-optee   = "targetcubemx_emmc-optee"
UBOOT_EXTLINUX_TARGETS_nand         = "targetcubemx_nand"
UBOOT_EXTLINUX_TARGETS_nor-emmc     = "targetcubemx_nor-emmc"
UBOOT_EXTLINUX_TARGETS_nor-sdcard   = "targetcubemx_nor-sdcard"
UBOOT_EXTLINUX_TARGETS_sdcard       = "targetcubemx_sdcard"
UBOOT_EXTLINUX_TARGETS_sdcard-optee = "targetcubemx_sdcard-optee"
# Define bootprefix for each target
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_emmc         = "${EXTLINUX_BOOTDEVICE_EMMC}_${CUBEMX_BOARD_REFERENCE}_"
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_emmc-optee   = "${EXTLINUX_BOOTDEVICE_EMMC}_${CUBEMX_BOARD_REFERENCE}-optee_"
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_nand         = "${EXTLINUX_BOOTDEVICE_NAND}_${CUBEMX_BOARD_REFERENCE}_"
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_nor-sdcard   = "${EXTLINUX_BOOTDEVICE_NORSDCARD}_${CUBEMX_BOARD_REFERENCE}_"
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_nor-emmc     = "${EXTLINUX_BOOTDEVICE_NOREMMC}_${CUBEMX_BOARD_REFERENCE}_"
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_sdcard       = "${EXTLINUX_BOOTDEVICE_SDCARD}_${CUBEMX_BOARD_REFERENCE}_"
UBOOT_EXTLINUX_BOOTPREFIXES_targetcubemx_sdcard-optee = "${EXTLINUX_BOOTDEVICE_SDCARD}_${CUBEMX_BOARD_REFERENCE}-optee_"
# Define labels for each target
UBOOT_EXTLINUX_LABELS_targetcubemx_emmc         = "cubemx-emmc"
UBOOT_EXTLINUX_LABELS_targetcubemx_emmc-optee   = "cubemx-emmc-optee"
UBOOT_EXTLINUX_LABELS_targetcubemx_nand         = "cubemx-nand"
UBOOT_EXTLINUX_LABELS_targetcubemx_nor-sdcard   = "cubemx-nor-sdcard"
UBOOT_EXTLINUX_LABELS_targetcubemx_nor-emmc     = "cubemx-nor-emmc"
UBOOT_EXTLINUX_LABELS_targetcubemx_sdcard       = "cubemx-sdcard"
UBOOT_EXTLINUX_LABELS_targetcubemx_sdcard-optee = "cubemx-sdcard-optee"
# Define default boot config for each target
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_emmc         ?= "cubemx-emmc"
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_emmc-optee   ?= "cubemx-emmc-optee"
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_nand         ?= "cubemx-nand"
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_nor-sdcard   ?= "cubemx-nor-sdcard"
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_nor-emmc     ?= "cubemx-nor-emmc"
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_sdcard       ?= "cubemx-sdcard"
UBOOT_EXTLINUX_DEFAULT_LABEL_targetcubemx_sdcard-optee ?= "cubemx-sdcard-optee"
# Define FDT overrides for all labels
UBOOT_EXTLINUX_FDT_cubemx-emmc       = "/${CUBEMX_DTB_SET}.dtb"
UBOOT_EXTLINUX_FDT_cubemx-emmc-optee = "/${CUBEMX_DTB_SET}.dtb"
UBOOT_EXTLINUX_FDT_cubemx-nand       = "/${CUBEMX_DTB_SET}.dtb"
UBOOT_EXTLINUX_FDT_cubemx-nor-emmc   = "/${CUBEMX_DTB_SET}.dtb"
UBOOT_EXTLINUX_FDT_cubemx-nor-sdcard = "/${CUBEMX_DTB_SET}.dtb"
UBOOT_EXTLINUX_FDT_cubemx-sdcard        = "/${CUBEMX_DTB_SET}.dtb"
UBOOT_EXTLINUX_FDT_cubemx-sdcard-optee  = "/${CUBEMX_DTB_SET}.dtb"
# Define ROOT overrides for all labels
UBOOT_EXTLINUX_ROOT_cubemx-emmc         = "${EXTLINUX_ROOT_EMMC}"
UBOOT_EXTLINUX_ROOT_cubemx-emmc-optee   = "${EXTLINUX_ROOT_EMMC_OPTEE}"
UBOOT_EXTLINUX_ROOT_cubemx-nand         = "${EXTLINUX_ROOT_NAND}"
UBOOT_EXTLINUX_ROOT_cubemx-nor-emmc     = "${EXTLINUX_ROOT_NOREMMC}"
UBOOT_EXTLINUX_ROOT_cubemx-nor-sdcard   = "${EXTLINUX_ROOT_NORSDCARD}"
UBOOT_EXTLINUX_ROOT_cubemx-sdcard       = "${EXTLINUX_ROOT_SDCARD}"
UBOOT_EXTLINUX_ROOT_cubemx-sdcard-optee = "${EXTLINUX_ROOT_SDCARD_OPTEE}"
