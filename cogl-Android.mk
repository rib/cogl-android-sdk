LOCAL_PATH := $(call my-dir)

# cogl
include $(CLEAR_VARS)

LOCAL_MODULE        := cogl
LOCAL_SRC_FILES     := lib/libcogl2.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/cogl2
LOCAL_EXPORT_LDLIBS := -lEGL
LOCAL_STATIC_LIBRARIES := glib-android gmodule gobject gthread

include $(PREBUILT_STATIC_LIBRARY)

# cogl-pango
#include $(CLEAR_VARS)
#
#LOCAL_MODULE        := cogl-pango
#LOCAL_SRC_FILES     := lib/libcogl-pango.a
#LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/cogl
#
#include $(PREBUILT_STATIC_LIBRARY)

$(call import-module,glib-android)
