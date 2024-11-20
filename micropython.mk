# This file is used by MicroPython Make-based builds such as the Unix port.
# For CMake-based builds, see the .cmake file in the same directory.

# This directory containing this file is to be given as 
#     make USER_C_MODULES=../../../../lvmp
# when building Micropython.

# See
#     https://github.com/lvgl/lv_micropython/blob/master/extmod/extmod.mk#L371
# and
#     https://github.com/lvgl-micropython/lvgl_micropython/blob/main/ext_mod/lvgl/micropython.mk

################################################################################
# LVGL build rules

$(shell mkdir -p $(BUILD))

LV_BINDINGS_DIR = $(USERMOD_DIR)
LVGL_DIR = $(LV_BINDINGS_DIR)/lvgl
LV_MP = $(BUILD)/lv_mp.c
LV_INCLUDE += -I$(LV_BINDINGS_DIR)
LV_PP = $(LV_MP).pp
LV_MPY_METADATA = $(LV_MP).json
LV_JSON = $(BUILD)/lvgl_all.json
LV_ALL_H = $(BUILD)/lvgl_all.h
LV_HEADERS = $(shell find $(LVGL_DIR) -type f -name '*.h') $(LV_BINDINGS_DIR)/lv_conf.h

CFLAGS_USERMOD += $(LV_CFLAGS)
CFLAGS_USERMOD += -I$(LV_BINDINGS_DIR)
CFLAGS_USERMOD += -I$(LVGL_DIR)
CFLAGS_USERMOD += -Wno-unused-function

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
$(LV_MP): $(LV_HEADERS) $(LV_BINDINGS_DIR)/gen_mpy.py $(LV_JSON)
	$(ECHO) "LVGL-GEN $@"
	$(Q)$(CPP) $(CFLAGS_USERMOD) -DPYCPARSER -x c -I $(LV_BINDINGS_DIR)/pycparser/utils/fake_libc_include $(LV_INCLUDE) $(LVGL_DIR)/lvgl.h > $(LV_PP)
	$(Q)$(PYTHON) $(LV_BINDINGS_DIR)/gen_mpy.py -M lvgl -MP lv -MD $(LV_MPY_METADATA) -E $(LV_PP) -J $(LV_JSON) $(LVGL_DIR)/lvgl.h > $@

.PHONY: LV_MP
LV_JSON: $(LV_JSON)
LV_MP: $(LV_MP)

SRC_USERMOD_C += $(LV_MP)
SRC_THIRDPARTY_C += $(subst $(TOP)/,,$(shell find $(LVGL_DIR)/src -type f -name "*.c"))
