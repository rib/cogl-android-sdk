LOCAL_PATH := $(call my-dir)

# freetype
include $(CLEAR_VARS)

LOCAL_MODULE        := freetype
LOCAL_SRC_FILES     := lib/libfreetype.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/freetype2

include $(PREBUILT_STATIC_LIBRARY)
