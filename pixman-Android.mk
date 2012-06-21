LOCAL_PATH := $(call my-dir)

# pixman
include $(CLEAR_VARS)

LOCAL_MODULE        := pixman
LOCAL_SRC_FILES     := lib/libpixman-1.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/pixman

include $(PREBUILT_STATIC_LIBRARY)
