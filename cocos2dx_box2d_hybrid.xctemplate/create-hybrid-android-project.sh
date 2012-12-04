#!/bin/bash
# This script only can be run under mac os.
# Don't modify the script until you know what you do.

# set environment paramters
NDK_ROOT_LOCAL="/Volumes/DATA/android-ndk-r8b"
ANDROID_SDK_ROOT_LOCAL="/Volumes/DATA/android-sdk-macosx"
COCOS2DX_SDK_ROOT_LOCAL="/Volumes/DATA/cocos2d-2.0-x-2.0.4"

NEED_BOX2D=true
NEED_CHIPMUNK=false
NEED_LUA=false

# try to get global variable
if [ $NDK_ROOT"aaa" != "aaa" ]; then
    echo "use global definition of NDK_ROOT: $NDK_ROOT"
    NDK_ROOT_LOCAL=$NDK_ROOT
fi

if [ $ANDROID_SDK_ROOT"aaa" != "aaa" ]; then
    echo "use global definition of ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
    ANDROID_SDK_ROOT_LOCAL=$ANDROID_SDK_ROOT
fi

# parameters passed to .bat or .sh
PARAMS=

print_usage(){
    echo ERROR!!!
}

# check if it was called by .bat file
if [ $# -ge 5 ];then
    if [ $5 = "windows" ];then
    echo "Error!!!"
    echo "Don't run in windows."
        exit
    fi
fi

# the bash file should not be called by cygwin
KERNEL_NAME=`uname -s | grep "CYGWIN*"`
if [ $KERNEL_NAME"hi" != "hi" ]; then
    echo "Error!!!"
    echo "Don't run in cygwin."
    exit
fi

# ok, it was run under linux

create_android_project(){
    echo "Input package path. For example: org.cocos2dx.example"
    read PACKAGE_PATH
    echo "Now cocos2d-x supports Android 2.2 or upper version"
    $ANDROID_SDK_ROOT_LOCAL/tools/android list targets
    echo "input target id:"
    read TARGET_ID
    echo "input your project name:"
    read PROJECT_NAME
    PROJECT_DIR=`pwd`/android
    
    # check if PROJECT_DIR is exist
    if [ -d $PROJECT_DIR ]; then
        echo "$PROJECT_DIR is exist, please remove it first."
        exit
    fi

    # Make project directory
    mkdir $PROJECT_DIR
    # Create Android project inside proj.android
    $ANDROID_SDK_ROOT_LOCAL/tools/android create project -n $PROJECT_NAME -t $TARGET_ID -k $PACKAGE_PATH -a $PROJECT_NAME -p $PROJECT_DIR
}

PARAMS=$@
create_android_project


#
# copy_files.sh
#

APP_NAME=$PROJECT_NAME
COCOS2DX_ROOT=$COCOS2DX_SDK_ROOT_LOCAL
APP_DIR=$PROJECT_DIR
HELLOWORLD_ROOT=$COCOS2DX_ROOT/samples/HelloCpp
COCOSJAVALIB_ROOT=$COCOS2DX_ROOT/cocos2dx/platform/android/java
NDK_ROOT=$NDK_ROOT_LOCAL
CUSTOM_DATA_DIR=create-hybrid-android-project

# xxx.yyy.zzz -> xxx/yyy/zzz
convert_package_path_to_dir(){
    PACKAGE_PATH_DIR=`echo $1 | sed -e "s/\./\//g"`
}

# from HelloWorld copy src and jni to APP_DIR
copy_src_and_jni(){
    cp -rf $HELLOWORLD_ROOT/proj.android/jni $APP_DIR
    cp -rf $HELLOWORLD_ROOT/proj.android/src $APP_DIR
    
    # replace Android.mk
#    cp -f $CUSTOM_DATA_DIR/Android.mk $APP_DIR/jni/Android.mk
     sed "s#__cocos2dxroot__#$COCOS2DX_ROOT#" $CUSTOM_DATA_DIR/Android.mk > $APP_DIR/jni/Android.mk
}

copy_library_src(){
    cp -rf $COCOSJAVALIB_ROOT/src/* $APP_DIR/src/
}

# copy build_native.sh and replace something
copy_build_native(){
    # here should use # instead of /, why??
    sed "s#__cocos2dxroot__#$COCOS2DX_ROOT#;s#__ndkroot__#$NDK_ROOT#;s#__projectname__#$APP_NAME#" $CUSTOM_DATA_DIR/build_native.sh > $APP_DIR/build_native.sh
    chmod u+x $APP_DIR/build_native.sh
}

# copy .project and .classpath and replace project name
modify_project_classpath(){
    sed "s/HelloCpp/$APP_NAME/" $COCOS2DX_ROOT/template/android/.project > $APP_DIR/.project
    cp -f $COCOS2DX_ROOT/template/android/.classpath $APP_DIR
}

# replace AndroidManifext.xml and change the activity name
# use sed to replace the specified line
modify_androidmanifest(){
    sed "s/HelloCpp/$APP_NAME/;s/org\.cocos2dx\.hellocpp/$PACKAGE_PATH/" $HELLOWORLD_ROOT/proj.android/AndroidManifest.xml > $APP_DIR/AndroidManifest.xml
}

# modify HelloCpp.java
modify_applicationdemo(){
    convert_package_path_to_dir $PACKAGE_PATH
    
    # rename APP_DIR/android/src/org/cocos2dx/hellocpp/HelloCpp.java to 
    # APP_DIR/android/src/org/cocos2dx/hellocpp/$APP_NAME.java, change hellocpp to game
    sed "s/HelloCpp/$APP_NAME/;s/org\.cocos2dx\.hellocpp/$PACKAGE_PATH/;s/hellocpp/game/" $APP_DIR/src/org/cocos2dx/hellocpp/HelloCpp.java > $APP_DIR/src/$PACKAGE_PATH_DIR/$APP_NAME.java    
    rm -fr $APP_DIR/src/org/cocos2dx/hellocpp
}

modify_layout(){
    rm -f $APP_DIR/res/layout/main.xml
}

# android.bat of android 4.0 don't create res/drawable-hdpi res/drawable-ldpi and res/drawable-mdpi.
# These work are done in ADT
copy_icon(){
    if [ ! -d $APP_DIR/proj.android/res/drawable-hdpi ]; then
        cp -r $HELLOWORLD_ROOT/proj.android/res/drawable-hdpi $APP_DIR/res
        cp -r $HELLOWORLD_ROOT/proj.android/res/drawable-ldpi $APP_DIR/res
        cp -r $HELLOWORLD_ROOT/proj.android/res/drawable-mdpi $APP_DIR/res
    fi
}

copy_src_and_jni
copy_library_src
copy_build_native
modify_project_classpath
modify_androidmanifest
modify_applicationdemo
modify_layout
copy_icon
