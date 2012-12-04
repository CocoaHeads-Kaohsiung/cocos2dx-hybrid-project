COCOS2DX_ROOT_PATH := __cocos2dxroot__

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := game_shared

LOCAL_MODULE_FILENAME := libgame

CLASS_PATH := $(LOCAL_PATH)/../../Classes

# add all source files automatically
dirs := $(shell find $(CLASS_PATH) -type d)
cppfilestemp1 := $(shell find $(CLASS_PATH) -type d)
cppfilestemp2 := $(shell find $(cppfilestemp1) -name *.cpp)
cppfilestemp3 := $(sort $(cppfilestemp2))
cppfiles := $(subst $(LOCAL_PATH)/,,$(cppfilestemp3))
LOCAL_SRC_FILES += $(cppfiles)
LOCAL_C_INCLUDES := $(cppfilestemp1)


LOCAL_C_INCLUDES += $(COCOS2DX_ROOT_PATH)/external/Box2D
                            
LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocosdenshion_static cocos_extension_static box2d_static
            
include $(BUILD_SHARED_LIBRARY)

$(call import-module,CocosDenshion/android) \
$(call import-module,cocos2dx) \
$(call import-module,extensions) $(call import-module,external/Box2D)
