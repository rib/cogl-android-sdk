LOCAL_PATH := $(call my-dir)

# iconv
include $(CLEAR_VARS)

LOCAL_MODULE := iconv
LOCAL_SRC_FILES := lib/libiconv.a

include $(PREBUILT_STATIC_LIBRARY)
