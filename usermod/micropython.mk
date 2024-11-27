# This file is used by MicroPython Make-based builds such as the Unix port.
# For CMake-based builds, see the .cmake file in the same directory.

# This directory containing this file is to be given as 
#     make USER_C_MODULES=../../../lv_micropython_cmod
# when building Micropython.

# See
#     https://github.com/lvgl/lv_micropython/blob/master/extmod/extmod.mk#L371
# and
#     https://github.com/lvgl-micropython/lvgl_micropython/blob/main/ext_mod/lvgl/micropython.mk

################################################################################
# LVGL build rules

$(shell mkdir -p $(BUILD))

LV_MICROPYTHON_DIR = $(USERMOD_DIR)/..
LVGL_DIR = $(LV_MICROPYTHON_DIR)/lvgl
LV_MP = $(BUILD)/lv_mp.c
LV_PP = $(LV_MP).pp
LV_MPY_METADATA = $(LV_MP).json
LV_JSON = $(BUILD)/lvgl_all.json
LV_ALL_H = $(BUILD)/lvgl_all.h
LV_HEADERS = $(shell find $(LVGL_DIR) -type f -name '*.h') $(LV_MICROPYTHON_DIR)/lv_conf.h

CFLAGS_USERMOD += -I$(LVGL_DIR)
CFLAGS_USERMOD += -I$(LV_MICROPYTHON_DIR)
CFLAGS_USERMOD += $(LV_CFLAGS)
CFLAGS_USERMOD += -Wno-unused-function

SRC_USERMOD_LIB_C += $(LV_MICROPYTHON_DIR)/lv_mem_core_micropython.c
SRC_USERMOD_LIB_C += $(shell find $(LVGL_DIR)/src -type f -name "*.c")
SRC_USERMOD_C += $(LV_MP)

# Create lvgl_all.h file (if gen_json.py exists) and lvgl_all.json file
ifneq (,$(wildcard $(LVGL_DIR)/scripts/gen_json/gen_json.py))
$(LV_JSON): $(LV_HEADERS) $(LVGL_DIR)/scripts/gen_json/gen_json.py
	$(ECHO) "LVGL-JSON-GEN $@"
	$(ECHO) "#include \"$(LVGL_DIR)/lvgl.h\"\n#include \"$(LVGL_DIR)/src/lvgl_private.h\"" > $(LV_ALL_H)
	$(Q)$(PYTHON) $(LVGL_DIR)/scripts/gen_json/gen_json.py --target-header $(LV_ALL_H) > $(LV_JSON)
else
$(LV_JSON):
	$(ECHO) "LVGL-JSON-GEN $@"
	$(ECHO) "{}" > $(LV_JSON)
endif

# Create lv_mp.c.pp and lv_mp.c files
$(LV_MP): $(LV_HEADERS) $(LV_MICROPYTHON_DIR)/gen_mpy.py $(LV_JSON)
	$(ECHO) "LVGL-GEN $@"
	$(Q)$(CPP) $(CFLAGS_USERMOD) -DPYCPARSER -x c -I $(LV_MICROPYTHON_DIR)/pycparser/utils/fake_libc_include -I$(LV_MICROPYTHON_DIR) $(LVGL_DIR)/lvgl.h > $(LV_PP)
	$(Q)$(PYTHON) $(LV_MICROPYTHON_DIR)/gen_mpy.py -M lvgl -MP lv -MD $(LV_MPY_METADATA) -E $(LV_PP) -J $(LV_JSON) $(LVGL_DIR)/lvgl.h > $@

.PHONY: LV_MP
LV_JSON: $(LV_JSON)
LV_MP: $(LV_MP)
