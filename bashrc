export ANDROID_NDK_DIR="$HOME/src/android/android-ndk-r7"
export ANDROID_NDK_TOOLCHAIN="$HOME/local/android-toolchain"
export ANDROID_SDK_DIR="$HOME/src/android-sdk-linux_86"

PATH="$PATH:$ANDROID_NDK_DIR:$ANDROID_NDK_TOOLCHAIN/bin"
PATH="$PATH:$ANDROID_SDK_DIR/tools/:$ANDROID_SDK_DIR/platform-tools"

export NDK_MODULE_PATH=$HOME/path/to/cogl-android-sdk/modules

if test "$#" -ge 1; then
   exec "$@";
fi
