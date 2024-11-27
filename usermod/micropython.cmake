# This file is used by MicroPython CMake-based builds such as the ESP32 and RP2 ports.
# For Make-based builds, see the .mk file in the same directory.

# When building Micropython, this file is to be given as:
#   for esp32:
#     make USER_C_MODULES=../../../../lv_micropython_cmod/usermod/micropython.cmake
#   for rp2 and most other (CMake-based) ports:
#     make USER_C_MODULES=../../../lv_micropython_cmod/usermod/micropython.cmake

find_package(Python3 REQUIRED COMPONENTS Interpreter)

set(LVMP_DIR ${CMAKE_CURRENT_LIST_DIR}/..)
set(LVMP_C ${CMAKE_BINARY_DIR}/lvmp.c)
set(LVMP_PP ${LVMP_C}.pp)
set(LVMP_JSON ${LVMP_C}.json)
set(LVGL_DIR ${LVMP_DIR}/lvgl)
file(GLOB_RECURSE SOURCES ${LVGL_DIR}/src/*.c ${LVMP_DIR}/lv_mem_core_micropython.c)

# Create lvmp.c.pp file
execute_process(
    COMMAND /bin/sh -c "${CMAKE_C_COMPILER} ${LV_CFLAGS} -E -DPYCPARSER -I ${LVMP_DIR}/pycparser/utils/fake_libc_include ${LVGL_DIR}/lvgl.h > ${LVMP_PP}"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Create lvmp.c.json and lvmp.c files
execute_process(
    COMMAND /bin/sh -c "${Python3_EXECUTABLE} ${LVMP_DIR}/gen_mpy.py -M lvgl -MP lv -MD ${LVMP_JSON} -E ${LVMP_PP} ${LVGL_DIR}/lvgl.h > ${LVMP_C} || (rm -f ${LVMP_C} && /bin/false)"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

add_library(lv_micropython INTERFACE)
target_sources(lv_micropython INTERFACE ${LVMP_C})
target_link_libraries(usermod INTERFACE lv_micropython)

add_library(lvgl INTERFACE)
target_sources(lvgl INTERFACE ${SOURCES})
target_compile_options(lvgl INTERFACE -Wno-unused-function)
target_link_libraries(lv_micropython INTERFACE lvgl)
