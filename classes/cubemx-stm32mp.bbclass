# Provides CubeMX device tree file management:
# User can configure recipe file so that extra device tree files provided by
# CubeMX can be integrated in original source code (and so get compiled)

# Configure generation of device tree binary with CubeMX output files
ENABLE_CUBEMX_DTB ??= "0"

# configure CubeMX device tree file check in source
ENABLE_CUBEMX_DTB_CHK ??= "1"

# CubeMX device tree file name
CUBEMX_DTB ??= ""
# Path to CubeMX project generated device tree files
CUBEMX_PROJECT ??= ""
# CubeMX project name
CUBEMX_PROJECT_NAME ??= ""

# CubeMX use external_dt class
inherit external-dt

EXTERNAL_DT_ENABLED:stm32mpcommonmx = "1"

STAGING_EXTDT_DIR:stm32mpcommonmx = "${@cubemx_search(d.getVar('CUBEMX_PROJECT'),d)[1]}"

EXTDT_DIR_TF_A:stm32mp13commonmx = "DeviceTree/${CUBEMX_PROJECT_NAME}/tf-a"
EXTDT_DIR_TF_A:stm32mp15commonmx = "CA7/DeviceTree/${CUBEMX_PROJECT_NAME}/tf-a"
EXTDT_DIR_TF_A:stm32mp2commonmx  = "CA35/DeviceTree/${CUBEMX_PROJECT_NAME}/tf-a"
EXTDT_DIR_TF_A_SERIAL:stm32mpcommonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', 'ExtMemLoader/DeviceTree/tf-a', '${EXTDT_DIR_TF_A}', d)}"
EXTDT_DIR_UBOOT:stm32mp13commonmx = "DeviceTree/${CUBEMX_PROJECT_NAME}/u-boot"
EXTDT_DIR_UBOOT:stm32mp15commonmx = "CA7/DeviceTree/${CUBEMX_PROJECT_NAME}/u-boot"
EXTDT_DIR_UBOOT:stm32mp2commonmx  = "CA35/DeviceTree/${CUBEMX_PROJECT_NAME}/u-boot"
EXTDT_DIR_UBOOT_SERIAL:stm32mpcommonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', 'ExtMemLoader/DeviceTree/u-boot', '${EXTDT_DIR_UBOOT}', d)}"
EXTDT_DIR_OPTEE:stm32mp13commonmx = "DeviceTree/${CUBEMX_PROJECT_NAME}/optee-os"
EXTDT_DIR_OPTEE:stm32mp15commonmx = "CA7/DeviceTree/${CUBEMX_PROJECT_NAME}/optee-os"
EXTDT_DIR_OPTEE:stm32mp2commonmx  = "CA35/DeviceTree/${CUBEMX_PROJECT_NAME}/optee-os"
EXTDT_DIR_OPTEE_SERIAL:stm32mpcommonmx = "${@bb.utils.contains('MACHINE_FEATURES', 'm33td', 'ExtMemLoader/DeviceTree/optee-os', '${EXTDT_DIR_OPTEE}', d)}"
EXTDT_DIR_LINUX:stm32mp13commonmx = "DeviceTree/${CUBEMX_PROJECT_NAME}/kernel"
EXTDT_DIR_LINUX:stm32mp15commonmx = "CA7/DeviceTree/${CUBEMX_PROJECT_NAME}/kernel"
EXTDT_DIR_LINUX:stm32mp2commonmx  = "CA35/DeviceTree/${CUBEMX_PROJECT_NAME}/kernel"

EXTDT_DIR_MCU:stm32mpcommonmx  = "CM33/DeviceTree/${CUBEMX_PROJECT_NAME}/mcuboot"
EXTDT_DIR_TF_M:stm32mpcommonmx = "CM33/DeviceTree/${CUBEMX_PROJECT_NAME}/tf-m"

# Configure makefile generation for external device tree file
CUBEMX_EXTDT_ENABLE_MK ??= "0"
# Do not force make file generation on recipe side when file already available
CUBEMX_EXTDT_FORCE_MK ??= "0"

def cubemx_search(dirs, d):
    """
    Manage CubeMX files location by looking for CubeMX project thanks to BBPATH
    Return true/false and absolute path to CubeMX project if found.
    """
    search_path = d.getVar("BBPATH").split(":")
    for dir in dirs.split():
        for p in search_path:
            dir_path = os.path.join(p, dir)
            if os.path.isdir(dir_path):
                return (True, dir_path)
    return (False, "")

python __anonymous() {
    if d.getVar('ENABLE_CUBEMX_DTB') == "0":
        return

    # Check that user has configured CubeMX machine properly
    cubemx_project = d.getVar('CUBEMX_PROJECT')
    if cubemx_project == "":
        raise bb.parse.SkipRecipe('\n[cubemx-stm32mp] CUBEMX_PROJECT var is empty. Please initalize it on your %s CubeMX machine configuration.\n' % d.getVar("MACHINE"))
    cubemx_dtb = d.getVar('CUBEMX_DTB')
    if cubemx_dtb == "":
        raise bb.parse.SkipRecipe('\n[cubemx-stm32mp] CUBEMX_DTB var is empty. Please initalize it on your %s CubeMX machine configuration.\n' % d.getVar("MACHINE"))

    # Check CubeMX project path according to CubeMX machine configuration
    found, cubemx_project_dir = cubemx_search(cubemx_project, d)
    if found:
        bb.debug(1, "Found CubeMX project absolute path: %s" % cubemx_project_dir)
    else:
        bbpaths = d.getVar('BBPATH').replace(':','\n\t')
        bb.fatal('\n[cubemx-stm32mp] Not able to find "%s" path from current BBPATH var:\n\t%s.' % (cubemx_project, bbpaths))

    if d.getVar('ENABLE_CUBEMX_DTB_CHK') == "1":
        # Append function to check before 'do_compile' that device tree file is available
        d.prependVarFlag('do_compile', 'prefuncs', "check_cubemx_extdt ")

    # Make sure to init CONFIGURE_FILES with proper STAGING_EXTDT_DIR
    for extdt_conf in d.getVar('EXTDT_DIR_CONFIG').split():
        provider = extdt_conf.split(':')[0]
        sub_path = extdt_conf.split(':')[1]
        if provider in d.getVar('PROVIDES').split():
            extdt_dir = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path)
            extdt_src_configure(d, extdt_dir)
            break
}

python check_cubemx_extdt() {
    for extdt_conf in d.getVar('EXTDT_DIR_CONFIG').split():
        provider = extdt_conf.split(':')[0]
        sub_path = extdt_conf.split(':')[1]
        if provider in d.getVar('PROVIDES').split():
            cubemx_dts_file = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path, d.getVar('CUBEMX_DTB') + '.dts')
            if os.path.exists(cubemx_dts_file):
                break
            elif d.getVar('EXTDT_USE_SUFFIX') == '1':
                found = False
                suffix_list = ""
                for storage in d.getVar('EXTDT_SUFFIX_STORAGE').split():
                    suffix = d.getVar('EXTDT_SUFFIX_%s' % storage) or ""
                    if suffix:
                        suffix_list += ' ' + suffix
                        cubemx_dts_raw = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path, d.getVar('CUBEMX_DTB'))
                        if os.path.exists(cubemx_dts_raw + suffix + '.dts'):
                            found = True
                            break
                if found:
                    break
                else:
                    bb.fatal('File %s[%s].dts not found: compilation aborted for %s device tree.' % (cubemx_dts_raw, suffix_list, d.getVar('BPN')))
            else:
                bb.fatal('File %s not found: compilation aborted for %s device tree.' % (cubemx_dts_file, d.getVar('BPN')))
}
