# This file is to be given as 
#     make USER_C_MODULES=../../../../lvmp/lvmp.cmake
# when building Micropython port

cmake_minimum_required(VERSION 3.12.4)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
find_program(AWK awk mawk gawk)

set(LV_BINDINGS_DIR ${CMAKE_CURRENT_LIST_DIR})
set(LVGL_DIR ${LV_BINDINGS_DIR}/lvgl)
set(LV_MP ${CMAKE_BINARY_DIR}/lv_mp.c)
set(LV_INCLUDE ${LV_BINDINGS_DIR})
set(LV_SRC ${LV_MP})
set(LV_MP ${CMAKE_BINARY_DIR}/lv_mp.c)
set(LV_PP ${LV_MP}.pp)
set(LV_MPY_METADATA ${LV_MP}.json)
set(LV_PP_FILTERED ${LV_PP})
set(LV_JSON ${CMAKE_BINARY_DIR}/lvgl_all.json)
set(LVGL_ALL_H ${CMAKE_BINARY_DIR}/lvgl_all.h)

file(GLOB_RECURSE SOURCES ${LVGL_DIR}/src/*.c)
file(GLOB_RECURSE LVGL_HEADERS ${LVGL_DIR}/src/*.h ${LV_BINDINGS_DIR}/lv_conf.h)


message(STATUS "Starting the CMake configuration for Micropython with LVGL bindings")

# Create lvgl_all.h file (if gen_json.py exists) and lvgl_all.json file
if (EXISTS ${LVGL_DIR}/scripts/gen_json/gen_json.py)
    set(LVGL_ALL_H ${CMAKE_BINARY_DIR}/lvgl_all.h)
    execute_process(
        COMMAND /bin/sh -c "echo '#include \"${LVGL_DIR}/lvgl.h\"' > ${LVGL_ALL_H}"
        COMMAND /bin/sh -c "echo '#include \"${LVGL_DIR}/src/lvgl_private.h\"' >> ${LVGL_ALL_H}"
        COMMAND ${Python3_EXECUTABLE} ${LVGL_DIR}/scripts/gen_json/gen_json.py --target-header ${LVGL_ALL_H} > ${LV_JSON}
        RESULT_VARIABLE result
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
else()
    execute_process(
        COMMAND /bin/sh -c "echo '{}' > ${LV_JSON}"
        RESULT_VARIABLE result
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endif()

# Create lv_mp.c.pp file
execute_process(
    COMMAND /bin/sh -c "${CMAKE_C_COMPILER} -E -DPYCPARSER ${LV_COMPILE_OPTIONS} ${LV_PP_OPTIONS} '${LV_CFLAGS}' -I ${LV_BINDINGS_DIR}/pycparser/utils/fake_libc_include ${MICROPY_CPP_FLAGS} ${LVGL_DIR}/lvgl.h > ${LV_PP}"
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Create lv_mp.c file
execute_process(
    COMMAND /bin/sh -c "${Python3_EXECUTABLE} ${LV_BINDINGS_DIR}/gen/gen_mpy.py -M lvgl -MP lv -MD ${LV_MPY_METADATA} -E ${LV_PP_FILTERED} -J ${LV_JSON} ${LVGL_DIR}/lvgl.h > ${LV_MP} || (rm -f ${LV_MP} && /bin/false)"
    RESULT_VARIABLE result
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


add_library(lvgl_interface INTERFACE)
# ${SOURCES} must NOT be given to add_library directly for some reason (won't be built)
target_sources(lvgl_interface INTERFACE ${SOURCES})
# Micropython builds with -Werror; we need to suppress some warnings, such as:
#
# /home/test/build/lv_micropython/ports/rp2/build-PICO/lv_mp.c:29316:16: error:
# 'lv_style_transition_dsc_t_path_xcb_callback' defined but not used
# [-Werror=unused-function] 29316 | STATIC int32_t
# lv_style_transition_dsc_t_path_xcb_callback(const lv_anim_t * arg0) |
# ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
target_compile_options(lvgl_interface INTERFACE -Wno-unused-function)


# lvgl bindings target (the mpy module)
add_library(usermod_lv_bindings INTERFACE)
target_sources(usermod_lv_bindings INTERFACE ${LV_SRC})
target_include_directories(usermod_lv_bindings INTERFACE ${LV_INCLUDE})
target_compile_options(usermod_lv_bindings INTERFACE ${LV_COMPILE_OPTIONS})


target_link_libraries(usermod_lv_bindings INTERFACE lvgl_interface)
# make usermod (target declared by Micropython for all user compiled modules) link to bindings
# this way the bindings (and transitively lvgl_interface) get proper compilation flags
target_link_libraries(usermod INTERFACE usermod_lv_bindings)


message(STATUS "Finished the CMake configuration for Micropython with LVGL bindings")
