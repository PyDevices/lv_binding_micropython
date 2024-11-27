# This file is used by MicroPython Make-based builds such as the Unix port.
# For CMake-based builds, see the .cmake file in the same directory.

# When building Micropython, the parent directory of this file's parent directory is to be given as:
#     make USER_C_MODULES=../../../lv_micropython_cmod

$(shell mkdir -p $(BUILD))

LVMP_DIR = $(USERMOD_DIR)/..
LVMP_C = $(BUILD)/lvmp.c
LVMP_PP = $(LVMP_C).pp
LVMP_JSON = $(LVMP_C).json
LVGL_DIR = $(LVMP_DIR)/lvgl
SOURCES = $(shell find $(LVGL_DIR)/src -type f -name "*.c")
SOURCES += $(LVMP_DIR)/lv_mem_core_micropython.c

# Create lvmp.c.pp, lvmp.c.json and lvmp.c files
$(LVMP_C): $(LVMP_DIR)/gen_mpy.py
	$(Q)$(CPP) $(LV_CFLAGS) -E -DPYCPARSER -I $(LVMP_DIR)/pycparser/utils/fake_libc_include $(LVGL_DIR)/lvgl.h > $(LVMP_PP)
	$(Q)$(PYTHON) $(LVMP_DIR)/gen_mpy.py -M lvgl -MP lv -MD $(LVMP_JSON) -E $(LVMP_PP) $(LVGL_DIR)/lvgl.h > $@

CFLAGS_USERMOD += -Wno-unused-function
SRC_USERMOD_LIB_C += $(SOURCES)
SRC_USERMOD_C += $(LVMP_C)

.PHONY: LVMP_C
LVMP_C: $(LVMP_C)
