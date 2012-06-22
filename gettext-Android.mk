LOCAL_PATH := $(call my-dir)

# gettext
include $(CLEAR_VARS)

LOCAL_MODULE        := intl
LOCAL_SRC_FILES     := lib/libintl.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := libiconv

include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,libiconv)
