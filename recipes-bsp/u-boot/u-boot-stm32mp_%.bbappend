# Configure recipe for CubeMX
inherit cubemx-stm32mp

# for generating external dt Makefile
SOC_UBOOT_CONFIG_SUPPORTED = "CONFIG_STM32MP13X CONFIG_STM32MP15X CONFIG_STM32MP21X CONFIG_STM32MP23X CONFIG_STM32MP25X"

# ------------------------------------------------
# Generate Makefile for usage of EXTERNAL DT with cubemx devicetree
# ------------------------------------------------
autogenerate_makefile_for_external_dt_cubemx() {
    [ "${ENABLE_CUBEMX_DTB}" -ne 1 ] && return
    [ "${CUBEMX_EXTDT_ENABLE_MK}" -ne 1 ] && return

    if [ -e "${STAGING_EXTDT_DIR}/${EXTDT_DIR_UBOOT}/Makefile" ]; then
        [ "${CUBEMX_EXTDT_FORCE_MK}" -ne 1 ] && return
    fi

    echo "# SPDX-License-Identifier: (GPL-2.0-only OR BSD-3-Clause)" > ${WORKDIR}/Makefile.external_dt
    echo "" >>  ${WORKDIR}/Makefile.external_dt

    dtb=$(echo "${STM32MP_DEVICETREE} ${STM32MP_DT_FILES_PROGRAMMER}" | tr ' ' '\n' | uniq | tr '\n' ' ')
    for supported in ${SOC_UBOOT_CONFIG_SUPPORTED}; do
        echo "dtb-\$(${supported}) += \\" >> ${WORKDIR}/Makefile.external_dt
        for soc in ${STM32MP_SOC_NAME}; do
            soc_maj=$(echo ${soc} | awk '{print toupper($0)}')
            [ "$(echo ${supported} | grep -c ${soc_maj})" -ne 1 ] && continue
            for devicetree in ${dtb}; do
                [ "$(echo ${devicetree} | grep -c ${soc})" -eq 1 ] && echo "     ${devicetree}.dtb \\" >> ${WORKDIR}/Makefile.external_dt
            done
        done
        echo "" >> ${WORKDIR}/Makefile.external_dt
        echo "" >> ${WORKDIR}/Makefile.external_dt
    done
    echo "#include \$(srctree)/scripts/Makefile.dts" >> ${WORKDIR}/Makefile.external_dt
    echo "" >> ${WORKDIR}/Makefile.external_dt
    echo "targets += \$(dtb-y)" >> ${WORKDIR}/Makefile.external_dt
    echo "" >> ${WORKDIR}/Makefile.external_dt
    echo "# Add any required device tree compiler flags here" >> ${WORKDIR}/Makefile.external_dt
    echo "DTC_FLAGS += -a 0x8" >> ${WORKDIR}/Makefile.external_dt
    echo "" >> ${WORKDIR}/Makefile.external_dt
    echo "PHONY += dtbs" >> ${WORKDIR}/Makefile.external_dt
    echo "dtbs: \$(addprefix \$(obj)/, \$(dtb-y))" >> ${WORKDIR}/Makefile.external_dt
    echo "	@:" >> ${WORKDIR}/Makefile.external_dt
    echo "" >> ${WORKDIR}/Makefile.external_dt
    echo "clean-files := *.dtb *.dtbo *_HS" >> ${WORKDIR}/Makefile.external_dt

    cp -f ${WORKDIR}/Makefile.external_dt ${STAGING_EXTDT_DIR}/${EXTDT_DIR_UBOOT}/Makefile
    # Duplicate same conf for EXTDT_DIR_OPTEE_SERIAL
    if [ -e "${STAGING_EXTDT_DIR}/${EXTDT_DIR_UBOOT_SERIAL}/Makefile" ]; then
        [ "${CUBEMX_EXTDT_FORCE_MK}" -ne 1 ] && return
    fi
    cp -f ${WORKDIR}/Makefile.external_dt ${STAGING_EXTDT_DIR}/${EXTDT_DIR_UBOOT_SERIAL}/Makefile
}
python() {
    machine_overrides = d.getVar('MACHINEOVERRIDES').split(':')
    if "stm32mpcommonmx" in machine_overrides:
        d.appendVarFlag('do_configure', 'prefuncs', ' autogenerate_makefile_for_external_dt_cubemx')
}
