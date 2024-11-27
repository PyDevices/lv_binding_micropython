metadata(
    description="lv_micropython modules",
    version="0.0.0",
)
module("lv_utils.py", base_path="./lib", opt=3)
module("lv_timer.py", base_path="./lib", opt=3)
try:
    include("$(BOARD_DIR)/manifest.py")
except Exception:
    try:
        include("$(PORT_DIR)/boards/manifest.py")
    except Exception:
        try:
            include("$(PORT_DIR)/variants/standard/manifest.py")
        except Exception:
            try:
                include("$(PORT_DIR)/variants/manifest.py")
            except Exception:
                pass
