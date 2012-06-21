LOCAL_PATH := $(call my-dir)

# cairo
include $(CLEAR_VARS)

LOCAL_MODULE        := cairo
LOCAL_SRC_FILES     := lib/libcairo.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/cairo

include $(PREBUILT_STATIC_LIBRARY)
