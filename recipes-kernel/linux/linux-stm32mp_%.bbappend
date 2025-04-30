# Configure recipe for CubeMX
inherit cubemx-stm32mp

# ------------------------------------------------
# Generate Kernel Makefile for usage of EXTERNAL DT with cubemx devicetree
# ------------------------------------------------
autogenerate_makefile_for_external_dt_cubemx() {
    [ "${ENABLE_CUBEMX_DTB}" -ne 1 ] && return
    [ "${CUBEMX_EXTDT_ENABLE_MK}" -ne 1 ] && return

    if [ -e "${STAGING_EXTDT_DIR}/${EXTDT_DIR_LINUX}/Makefile" ]; then
        [ "${CUBEMX_EXTDT_FORCE_MK}" -ne 1 ] && return
    fi

    echo "# SPDX-License-Identifier: GPL-2.0-only" > ${WORKDIR}/Makefile.external_dt
    echo "" >>  ${WORKDIR}/Makefile.external_dt

    dtb=$(echo ${STM32MP_DEVICETREE} | tr ' ' '\n' | uniq | tr '\n' ' ')
    if [ "${ARCH}" = "arm" ]; then
        echo "dtb-\$(TARGET_ARM32) += \\" >> ${WORKDIR}/Makefile.external_dt
        for devicetree in ${dtb}; do
            echo "    ${devicetree}.dtb \\" >> ${WORKDIR}/Makefile.external_dt
        done
        echo "" >> ${WORKDIR}/Makefile.external_dt
    fi
    if [ "${ARCH}" = "arm64" ]; then
        echo "dtb-\$(TARGET_ARM64) += \\" >> ${WORKDIR}/Makefile.external_dt
        for devicetree in ${dtb}; do
            echo "    ${devicetree}.dtb \\" >> ${WORKDIR}/Makefile.external_dt
        done
        echo "" >> ${WORKDIR}/Makefile.external_dt
    fi

    cp -f ${WORKDIR}/Makefile.external_dt ${STAGING_EXTDT_DIR}/${EXTDT_DIR_LINUX}/Makefile

}
python() {
    machine_overrides = d.getVar('MACHINEOVERRIDES').split(':')
    if "stm32mpcommonmx" in machine_overrides:
        d.appendVarFlag('do_configure', 'prefuncs', ' autogenerate_makefile_for_external_dt_cubemx')
}
