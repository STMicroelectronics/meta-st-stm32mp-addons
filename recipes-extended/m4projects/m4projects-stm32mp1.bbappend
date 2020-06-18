PROJECTS_LIST_stm32mpcommonmx = " \
${@bb.utils.contains('PROJECTS_LIST_EV1', 'STM32MP157C-EV1/Applications/OpenAMP/OpenAMP_TTY_echo', 'STM32MP157C-EV1/Applications/OpenAMP/OpenAMP_TTY_echo', '', d)} \
${@bb.utils.contains('PROJECTS_LIST_DK2', 'STM32MP157C-DK2/Applications/OpenAMP/OpenAMP_TTY_echo', 'STM32MP157C-DK2/Applications/OpenAMP/OpenAMP_TTY_echo', '', d)} \
"
