# Configure recipe for CubeMX
EXTERNALSRC:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_CUBEMX_DTB', '1', '${STAGING_EXTDT_DIR}', '', d)}"
EXTERNALSRC_BUILD:stm32mpcommonmx = "${@bb.utils.contains('ENABLE_CUBEMX_DTB', '1', '${STAGING_EXTDT_DIR}', '', d)}"
