LOCAL_PATH := $(call my-dir)

# rig
include $(CLEAR_VARS)

LOCAL_MODULE        := rig
LOCAL_SRC_FILES     := lib/librig.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/rig
LOCAL_STATIC_LIBRARIES := cogl-pango

include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,cogl)
