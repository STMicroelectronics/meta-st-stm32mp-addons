# Provides CubeMX device tree file management:
# User can configure recipe file so that extra device tree files provided by
# CubeMX can be integrated in original source code (and so get compiled)

# Configure generation of device tree binary with CubeMX output files
ENABLE_CUBEMX_DTB ??= "0"

# CubeMX device tree file name
CUBEMX_DTB ??= ""
# Path to CubeMX project generated device tree files
CUBEMX_PROJECT ??= ""
# Path to specific CubeMX device tree file (*.dts file) to build
CUBEMX_DTB_PATH ??= ""
# Component path to copy CubeMX device tree file
CUBEMX_DTB_SRC_PATH ??= ""

# Internal class variable to manage CubeMX file location:
#   CUBEMX_PROJECT_ABS
#       Absolute path to CubeMX project generated device tree files, initialized
#       thanks to BBPATH
#   CUBEMX_DTB_PATH_FULL
#       Absolute path to CubeMX device tree file
CUBEMX_PROJECT_ABS = ""
CUBEMX_DTB_PATH_FULL = "${CUBEMX_PROJECT_ABS}/${CUBEMX_DTB_PATH}"

# Append to CONFIGURE_FILES var the CubeMX device tree file to make sure that
# any device tree file update implies new compilation
CONFIGURE_FILES += "${@' '.join(map(str, ('${CUBEMX_DTB_PATH_FULL}'+'/'+f for f in os.listdir('${CUBEMX_DTB_PATH_FULL}')))) if os.path.isdir(d.getVar('CUBEMX_DTB_PATH_FULL')) else ''}"

# Append to EXTERNALSRC_SYMLINKS var the CubeMX device tree config to manage
# symlink creation through externalsrc class
EXTERNALSRC_SYMLINKS += "${@' '.join(map(str, ('${CUBEMX_DTB_SRC_PATH}'+'/'+f+':'+'${CUBEMX_DTB_PATH_FULL}'+'/'+f for f in os.listdir('${CUBEMX_DTB_PATH_FULL}')))) if os.path.isdir(d.getVar('CUBEMX_DTB_PATH_FULL')) else ''}"

python __anonymous() {
    if d.getVar('ENABLE_CUBEMX_DTB') == "0":
        return

    # Check that user has configured CubeMX machine properly
    cubemx_project = d.getVar('CUBEMX_PROJECT')
    if cubemx_project == "":
        raise bb.parse.SkipRecipe('\n[cubemx-stm32mp] CUBEMX_PROJECT var is empty. Please initalize it on your %s CubeMX machine configuration.' % d.getVar("MACHINE"))
    cubemx_dtb = d.getVar('CUBEMX_DTB')
    if cubemx_dtb == "":
        raise bb.parse.SkipRecipe('\n[cubemx-stm32mp] CUBEMX_DTB var is empty. Please initalize it on your %s CubeMX machine configuration.' % d.getVar("MACHINE"))

    # Set CUBEMX_PROJECT_ABS according to CubeMX machine configuration
    found, cubemx_project_dir = cubemx_search(cubemx_project, d)
    if found:
        bb.debug(1, "Set CUBEMX_PROJECT_ABS to '%s' path." % cubemx_project_dir)
        d.setVar('CUBEMX_PROJECT_ABS', cubemx_project_dir)
    else:
        bbpaths = d.getVar('BBPATH').replace(':','\n\t')
        bb.fatal('\n[cubemx-stm32mp] Not able to find "%s" path from current BBPATH var:\n\t%s.' % (cubemx_project, bbpaths))

    # In order to take care of any change in CUBEMX_DTB file when user has not set
    # recipe source code management through devtool, we should add the same extra
    # file checksums for the 'do_configure' task than the one done in externalsrc
    # class
    externalsrc = d.getVar('EXTERNALSRC')
    if not externalsrc:
        d.prependVarFlag('do_configure', 'prefuncs', "externalsrc_configure_prefunc ")
        d.setVarFlag('do_configure', 'file-checksums', '${@srctree_configure_hash_files(d)}')

    # Append function to check before 'do_compile' that device tree file is available
    d.prependVarFlag('do_compile', 'prefuncs', "check_cubemxdtb_exist ")
}

def cubemx_search(dirs, d):
    search_path = d.getVar("BBPATH").split(":")
    for dir in dirs.split():
        for p in search_path:
            dir_path = os.path.join(p, dir)
            if os.path.isdir(dir_path):
                return (True, dir_path)
    return (False, "")

python check_cubemxdtb_exist() {
    cubemx_dts_file = os.path.join(d.getVar('CUBEMX_DTB_PATH_FULL'), d.getVar('CUBEMX_DTB') + '.dts')
    # Abort compilation and alert user in case CubeMX device tree file is not available
    if not os.path.exists(cubemx_dts_file):
        bb.fatal('File %s not found: compilation aborted for %s device tree.' % (cubemx_dts_file, d.getVar('PN')))
}

# =========================================================================
# Import and adapt functions from openembedded-core 'externalsrc.bbclass'
# =========================================================================

python externalsrc_configure_prefunc() {
    s_dir = d.getVar('S')
    # Create desired symlinks
    symlinks = (d.getVar('EXTERNALSRC_SYMLINKS') or '').split()
    newlinks = []
    for symlink in symlinks:
        symsplit = symlink.split(':', 1)
        lnkfile = os.path.join(s_dir, symsplit[0])
        target = d.expand(symsplit[1])
        if len(symsplit) > 1:
            if os.path.islink(lnkfile):
                # Link already exists, leave it if it points to the right location already
                if os.readlink(lnkfile) == target:
                    continue
                os.unlink(lnkfile)
            elif os.path.exists(lnkfile):
                # File/dir exists with same name as link, just leave it alone
                continue
            os.symlink(target, lnkfile)
            newlinks.append(symsplit[0])
    # Hide the symlinks from git
    try:
        git_exclude_file = os.path.join(s_dir, '.git/info/exclude')
        if os.path.exists(git_exclude_file):
            with open(git_exclude_file, 'r+') as efile:
                elines = efile.readlines()
                for link in newlinks:
                    if link in elines or '/'+link in elines:
                        continue
                    efile.write('/' + link + '\n')
    except IOError as ioe:
        bb.note('Failed to hide EXTERNALSRC_SYMLINKS from git')
}

def srctree_configure_hash_files(d):
    """
    Get the list of files that should trigger do_configure to re-execute,
    based on the value of CONFIGURE_FILES
    """
    in_files = (d.getVar('CONFIGURE_FILES') or '').split()
    out_items = []
    search_files = []
    for entry in in_files:
        if entry.startswith('/'):
            out_items.append('%s:%s' % (entry, os.path.exists(entry)))
        else:
            search_files.append(entry)
    if search_files:
        #s_dir = d.getVar('EXTERNALSRC')
        s_dir = d.getVar('S')
        for root, _, files in os.walk(s_dir):
            for f in files:
                if f in search_files:
                    out_items.append('%s:True' % os.path.join(root, f))
    return ' '.join(out_items)
