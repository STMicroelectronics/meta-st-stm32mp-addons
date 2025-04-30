# Configure recipe for CubeMX
inherit cubemx-stm32mp

python () {
    ddr_size = d.getVar('CUBEMX_BOARD_DDR_SIZE')
    if ddr_size is not None:
        size = int(ddr_size) * 1024 * 1024
        d.setVar('CUBEMX_BOARD_DDR_SIZE_HEXA', "0x%x" % size)
    else:
        d.setVar('CUBEMX_BOARD_DDR_SIZE_HEXA', "")
}

# Manage DDR size value
EXTRA_OEMAKE += "${@'CFG_DRAM_SIZE=${CUBEMX_BOARD_DDR_SIZE_HEXA}' if (d.getVar('CUBEMX_BOARD_DDR_SIZE_HEXA') != '') else '' }"

# for generating external dt Makefile
SOC_OPTEE_CONFIG_SUPPORTED = "MP13 MP15 MP21 MP23 MP25"

# Configure for optee TA
ST_OPTEE_EXPORT_TA_REF_BOARD:stm32mpcommonmx = "${CUBEMX_DTB}.dts"
ST_OPTEE_EXPORT_TA_OEMAKE_EXTRA:stm32mpcommonmx = "CFG_EXT_DTS=${STAGING_EXTDT_DIR}/${EXTDT_DIR_OPTEE}"

# ------------------------------------------------
# Generate optee conf for usage of EXTERNAL DT with cubemx devicetree
# ------------------------------------------------
autogenerate_conf_for_external_dt_cubemx() {
    [ "${ENABLE_CUBEMX_DTB}" -ne 1 ] && return
    [ "${CUBEMX_EXTDT_ENABLE_MK}" -ne 1 ] && return

    if [ -e "${STAGING_EXTDT_DIR}/${EXTDT_DIR_OPTEE}/conf.mk" ]; then
        [ "${CUBEMX_EXTDT_FORCE_MK}" -ne 1 ] && return
    fi

    echo "# SPDX-License-Identifier: BSD-2-Clause" > ${WORKDIR}/conf.external_dt
    echo "" >>  ${WORKDIR}/conf.external_dt

    dtb=$(echo "${STM32MP_DEVICETREE} ${STM32MP_DT_FILES_PROGRAMMER}" | tr ' ' '\n' | uniq | tr '\n' ' ')
    for supported in ${SOC_OPTEE_CONFIG_SUPPORTED}; do
        echo "# ${supported} boards" >> ${WORKDIR}/conf.external_dt
        for soc in ${STM32MP_SOC_NAME}; do
            soc_maj=$(echo ${soc} | awk '{print toupper($0)}')
            [ "$(echo ${soc_maj} | grep -c ${supported})" -ne 1 ] && continue

            dtb_by_soc=""
            for devicetree in ${dtb}; do
                [ "$(echo ${devicetree} | grep -c ${soc})" -eq 1 ] && dtb_by_soc="${dtb_by_soc} ${devicetree}.dts"
                # Set soc_package
                soc_package=$(echo ${devicetree} | cut -d'-' -f1 | awk '{print substr($0,length,1)}')
            done
            echo "flavor_dts_file-${supported}-CUBEMX = ${dtb_by_soc}" >> ${WORKDIR}/conf.external_dt
            if [ "${soc}" = "stm32mp13" ] || [ "${soc}" = "stm32mp15" ]; then
                # Configure SOC PACKAGE (MP13 and MP15 only):
                #   - a: no crypt
                #   - c: crypt
                #   - d: no crypt, performance
                #   - f: crypt, performance
                if [ "${soc_package}" = "a" ] || [ "${soc_package}" = "d" ]; then
                    echo "flavorlist-no_cryp = \$(flavor_dts_file-${supported}-CUBEMX)" >> ${WORKDIR}/conf.external_dt
                fi
            fi
            # Configure platform specific ddr size
            case ${CUBEMX_BOARD_DDR_SIZE} in
                512)
                    echo "flavorlist-512M = \$(flavor_dts_file-${supported}-CUBEMX)" >> ${WORKDIR}/conf.external_dt
                    ;;
                1024)
                    echo "flavorlist-1G = \$(flavor_dts_file-${supported}-CUBEMX)" >> ${WORKDIR}/conf.external_dt
                    ;;
                *)
                    ;;
            esac
            if ${@bb.utils.contains('MACHINE_FEATURES','m33td','true','false',d)}; then
                echo "flavorlist-M33-TDCID = \$(flavor_dts_file-${supported}-CUBEMX)" >> ${WORKDIR}/conf.external_dt
            fi

            echo "flavorlist-${supported} += \$(flavor_dts_file-${supported}-CUBEMX)" >> ${WORKDIR}/conf.external_dt
        done
        echo "" >> ${WORKDIR}/conf.external_dt
    done
    echo "" >> ${WORKDIR}/conf.external_dt

    cp -f ${WORKDIR}/conf.external_dt ${STAGING_EXTDT_DIR}/${EXTDT_DIR_OPTEE}/conf.mk

    # Duplicate same conf for EXTDT_DIR_OPTEE_SERIAL
    if [ -e "${STAGING_EXTDT_DIR}/${EXTDT_DIR_OPTEE_SERIAL}/conf.mk" ]; then
        [ "${CUBEMX_EXTDT_FORCE_MK}" -ne 1 ] && return
    fi
    cp -f ${WORKDIR}/conf.external_dt ${STAGING_EXTDT_DIR}/${EXTDT_DIR_OPTEE_SERIAL}/conf.mk
}
python() {
    machine_overrides = d.getVar('MACHINEOVERRIDES').split(':')
    if "stm32mpcommonmx" in machine_overrides:
        d.appendVarFlag('do_configure', 'prefuncs', ' autogenerate_conf_for_external_dt_cubemx')
}
