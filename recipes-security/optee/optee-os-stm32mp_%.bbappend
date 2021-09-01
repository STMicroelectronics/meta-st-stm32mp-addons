# Configure recipe for CubeMX
inherit cubemx-stm32mp

CUBEMX_DTB_PATH_OPTEEOS ?= "optee-os"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_OPTEEOS}"

CUBEMX_DTB_SRC_PATH ?= "core/arch/arm/dts"

python () {
    soc_package = (d.getVar('CUBEMX_SOC_PACKAGE') or "").split()
    if len(soc_package) > 1:
        bb.fatal('The CUBEMX_SOC_PACKAGE is initialized to: %s ! This var should only contains ONE package version' % soc_package)

    ddr_size = d.getVar('CUBEMX_BOARD_DDR_SIZE')
    if ddr_size is not None:
        size = int(ddr_size) * 1024 * 1024
        d.setVar('CUBEMX_BOARD_DDR_SIZE_HEXA', "0x%x" % size)
    else:
        d.setVar('CUBEMX_BOARD_DDR_SIZE_HEXA', "")
}

# manage paramater value
# PACKAGE OF SOC
CUBEMX_SOC_PACKAGE_option = "\
    ${@bb.utils.contains_any('CUBEMX_SOC_PACKAGE', [ 'A', 'D' ], 'CFG_STM32_CRYP=n', '', d)} \
    ${@bb.utils.contains_any('CUBEMX_SOC_PACKAGE', [ 'C', 'F' ], 'CFG_STM32_CRYP=y', '', d)} \
    "
# Memory size
CUBEMX_BOARD_DDR_SIZE_option = "\
    ${@'CFG_DRAM_SIZE=${CUBEMX_BOARD_DDR_SIZE_HEXA}' if (d.getVar('CUBEMX_BOARD_DDR_SIZE_HEXA') != '') else '' } \
    "
# DVFS OFF
CUBEMX_SOC_DVFS_OFF_option = "\
    ${@bb.utils.contains('CUBEMX_SOC_DVFS_OFF', '1', 'CFG_STM32MP1_CPU_OPP=n FG_SCMI_MSG_PERF_DOMAIN=n', '', d)} \
    "

EXTRA_OEMAKE += "${CUBEMX_SOC_PACKAGE_option} ${CUBEMX_BOARD_DDR_SIZE_option} ${CUBEMX_SOC_DVFS_OFF_option}"

