LOCAL_PATH := $(call my-dir)

# cairo
include $(CLEAR_VARS)

LOCAL_MODULE        := cairo
LOCAL_SRC_FILES     := lib/libcairo.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/cairo
LOCAL_STATIC_LIBRARIES := libpng fontconfig pixman

include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,libpng)
$(call import-module,fontconfig)
$(call import-module,pixman)
