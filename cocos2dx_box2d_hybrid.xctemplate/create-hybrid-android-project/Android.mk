COCOS2DX_ROOT_PATH := __cocos2dxroot__

LOCAL_PATH := $(call my-dir)

$(info *** LOCAL_PATH: $(LOCAL_PATH))

include $(CLEAR_VARS)

LOCAL_MODULE := game_shared

LOCAL_MODULE_FILENAME := libgame

#LOCAL_SRC_FILES := hellocpp/main.cpp \
#                   ../../Classes/AppDelegate.cpp \
#                   ../../Classes/HelloWorldScene.cpp \
#                   ../../Classes/GLES-Render.cpp
SRC_FILE_LIST := $(addprefix ../,$(wildcard ../Classes/*.cpp))
LOCAL_SRC_FILES := hellocpp/main.cpp \
                   $(SRC_FILE_LIST)
              
$(info *** LOCAL_SRC_FILES: $(LOCAL_SRC_FILES))
                   
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes \
					$(COCOS2DX_ROOT_PATH)/external/Box2D

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocosdenshion_static cocos_extension_static box2d_static
            
include $(BUILD_SHARED_LIBRARY)

$(call import-module,CocosDenshion/android) \
$(call import-module,cocos2dx) \
$(call import-module,extensions) \
$(call import-module,external/Box2D)
