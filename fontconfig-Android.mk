LOCAL_PATH := $(call my-dir)

# fontconfig
include $(CLEAR_VARS)

LOCAL_MODULE        := fontconfig
LOCAL_SRC_FILES     := lib/libfontconfig.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include
LOCAL_STATIC_LIBRARIES := freetype expat

include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,freetype)
$(call import-module,expat)
