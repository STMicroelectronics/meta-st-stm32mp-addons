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

# Internal class variable to manage CubeMX file location:
#   CUBEMX_PROJECT_ABS
#       Absolute path to CubeMX project generated device tree files, initialized
#       thanks to BBPATH
CUBEMX_PROJECT_ABS = ""

# CubeMX use external_dt class
inherit external-dt

EXTERNAL_DT_ENABLED:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_CUBEMX_DTB', '1', '1', '0', d)}"

STAGING_EXTDT_DIR:stm32mpcommonmx = "${CUBEMX_PROJECT_ABS}"

EXTDT_DIR_TF_A:stm32mpcommonmx  = "tf-a"
EXTDT_DIR_UBOOT:stm32mpcommonmx = "u-boot"
EXTDT_DIR_TF_M:stm32mpcommonmx  = "tf-m"
EXTDT_DIR_OPTEE:stm32mpcommonmx = "optee-os"
EXTDT_DIR_LINUX:stm32mpcommonmx = "kernel"

# Do not force make file generation on recipe side when file already available
CUBEMX_EXTDT_FORCE_MK ??= "0"

def cubemx_search(dirs, d):
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

    # Set CUBEMX_PROJECT_ABS according to CubeMX machine configuration
    found, cubemx_project_dir = cubemx_search(cubemx_project, d)
    if found:
        bb.debug(1, "Set CUBEMX_PROJECT_ABS to '%s' path." % cubemx_project_dir)
        d.setVar('CUBEMX_PROJECT_ABS', cubemx_project_dir)
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
            cubemx_dts_file_ns = os.path.join(d.getVar('STAGING_EXTDT_DIR'), sub_path, d.getVar('CUBEMX_DTB') + '-ns.dts')
            if os.path.exists(cubemx_dts_file):
                break
            elif os.path.exists(cubemx_dts_file_ns):
                break
            else:
                bb.fatal('File %s not found: compilation aborted for %s device tree.' % (cubemx_dts_file, d.getVar('BPN')))
}
