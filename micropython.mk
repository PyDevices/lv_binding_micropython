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

LVGL_BINDING_DIR = $(USERMOD_DIR)
LVGL_DIR = $(LVGL_BINDING_DIR)/lvgl
INC += -I$(LVGL_BINDING_DIR)
ALL_LVGL_SRC = $(shell find $(LVGL_DIR) -type f -name '*.h') $(LVGL_BINDING_DIR)/lv_conf.h
LVGL_ALL_H = $(BUILD)/lvgl/lvgl_all.h
LVGL_ALL_JSON = $(BUILD)/lvgl/lvgl_all.json
LVGL_PP = $(BUILD)/lvgl/lvgl.pp.c
LVGL_MPY = $(BUILD)/lvgl/lv_mpy.c
LVGL_MPY_METADATA = $(BUILD)/lvgl/lv_mpy.json
CFLAGS_USERMOD += $(LV_CFLAGS) 

ifneq (,$(wildcard $(LVGL_DIR)/scripts/gen_json/gen_json.py))
$(LVGL_ALL_JSON): $(ALL_LVGL_SRC) $(LVGL_DIR)/scripts/gen_json/gen_json.py
	$(ECHO) "LVGL-JSON-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(ECHO) "#include \"$(LVGL_DIR)/lvgl.h\"\n#include \"$(LVGL_DIR)/src/lvgl_private.h\"" > $(LVGL_ALL_H)
	$(Q)$(PYTHON) $(LVGL_DIR)/scripts/gen_json/gen_json.py --target-header $(LVGL_ALL_H) > $(LVGL_ALL_JSON)
else
$(LVGL_ALL_JSON):
	$(ECHO) "LVGL-JSON-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(ECHO) "{}" > $(LVGL_ALL_JSON)
endif

$(LVGL_MPY): $(ALL_LVGL_SRC) $(LVGL_BINDING_DIR)/gen/gen_mpy.py $(LVGL_ALL_JSON)
	$(ECHO) "LVGL-GEN $@"
	$(Q)mkdir -p $(dir $@)
	$(Q)$(CPP) $(CFLAGS_EXTMOD) -DPYCPARSER -x c -I $(LVGL_BINDING_DIR)/pycparser/utils/fake_libc_include $(INC) $(LVGL_DIR)/lvgl.h > $(LVGL_PP)
	$(Q)$(PYTHON) $(LVGL_BINDING_DIR)/gen/gen_mpy.py -M lvgl -MP lv -MD $(LVGL_MPY_METADATA) -E $(LVGL_PP) -J $(LVGL_ALL_JSON) $(LVGL_DIR)/lvgl.h > $@

.PHONY: LVGL_MPY
LVGL_ALL_JSON: $(LVGL_ALL_JSON)
LVGL_MPY: $(LVGL_MPY)

CFLAGS_USERMOD += -Wno-unused-function
SRC_THIRDPARTY_C += $(subst $(TOP)/,,$(shell find $(LVGL_DIR)/src -type f -name "*.c"))
SRC_USERMOD += $(LVGL_MPY)
