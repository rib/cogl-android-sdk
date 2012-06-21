LOCAL_PATH := $(call my-dir)

# pango
include $(CLEAR_VARS)

LOCAL_MODULE        := pango
LOCAL_SRC_FILES     := lib/libpango-1.0.a
LOCAL_EXPORT_CFLAGS := -I$(LOCAL_PATH)/include/pango-1.0

include $(PREBUILT_STATIC_LIBRARY)

# pangoft2
include $(CLEAR_VARS)

LOCAL_MODULE        := pangoft2
LOCAL_SRC_FILES     := lib/libpangoft2-1.0.a

include $(PREBUILT_STATIC_LIBRARY)

# pangocairo
include $(CLEAR_VARS)

LOCAL_MODULE        := pangocairo
LOCAL_SRC_FILES     := lib/libpangocairo-1.0.a

include $(PREBUILT_STATIC_LIBRARY)
