LOCAL_PATH := $(call my-dir)

# fontconfig
include $(CLEAR_VARS)

LOCAL_MODULE        := fontconfig
LOCAL_SRC_FILES     := lib/libfontconfig.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include

include $(PREBUILT_STATIC_LIBRARY)
