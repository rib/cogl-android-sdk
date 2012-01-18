LOCAL_PATH := $(call my-dir)

# gettext
include $(CLEAR_VARS)

LOCAL_MODULE        := intl
LOCAL_SRC_FILES     := lib/libintl.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include

include $(PREBUILT_STATIC_LIBRARY)
