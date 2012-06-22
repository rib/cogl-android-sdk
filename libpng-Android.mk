LOCAL_PATH := $(call my-dir)

# libpng
include $(CLEAR_VARS)

LOCAL_MODULE        := png
LOCAL_SRC_FILES     := lib/libpng15.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/libpng15
LOCAL_EXPORT_LDLIBS := -lz

include $(PREBUILT_STATIC_LIBRARY)
