#!/bin/sh

set -x

# Please read the README before running this script!

if test -z "$COGL_ANDROID_SDK_DIR"; then
    COGL_ANDROID_SDK_DIR=$PWD
fi
if ! test -f $COGL_ANDROID_SDK_DIR/cogl-Android.mk; then
    echo "build.sh must be run from the top of the cogl-android-sdk directory"
    exit 1
fi

SOURCE_PACKAGES="\
    http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz \
    http://ftp.gnu.org/gnu/gettext/gettext-0.18.tar.gz \
    ftp://ftp.isc.org/isc/libbind/6.0/libbind-6.0.tar.gz \
    http://ftp.acc.umu.se/pub/GNOME/sources/glib/2.29/glib-2.29.2.tar.bz2 \
    ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.9.tar.xz \
    http://fossies.org/unix/www/expat-2.0.1.tar.gz \
    http://download.savannah.gnu.org/releases/freetype/freetype-2.4.6.tar.bz2"

GIT_REPOS="\
    git://git.gnome.org/cogl.git@bbcbece6c976fbf \
    https://github.com/dlespiau/glib-android.git@29922cd171895"

CONFIG_GUESS_URL="http://git.savannah.gnu.org/gitweb/?p=automake.git;a=blob_plain;f=lib/config.guess"
CONFIG_SUB_URL="http://git.savannah.gnu.org/gitweb/?p=automake.git;a=blob_plain;f=lib/config.sub"

function guess_dir ()
{
    local var="$1"; shift;
    local suffix="$1"; shift;
    local msg="$1"; shift;
    local prompt="$1"; shift;
    local dir="${!var}";

    if [ -z "$dir" ]; then
	echo "Please enter ${msg}.";
	dir="$PWD/$suffix";
	read -r -p "$prompt [$dir] ";
	if [ -n "$REPLY" ]; then
	    dir="$REPLY";
	fi;
    fi;

    eval $var="\"$dir\"";

    if [ ! -d "$dir" ]; then
	if ! mkdir -p "$dir"; then
	    echo "Error making directory $dir";
	    exit 1;
	fi;
    fi;
}

# If a download directory hasn't been specified then try to guess one
# but ask for confirmation first
guess_dir DOWNLOAD_DIR "downloads" \
    "the directory to download to" "Download directory";

# If a download directory hasn't been specified then try to guess one
# but ask for confirmation first
guess_dir BUILD_DIR "build" \
    "the directory to build in" "Build directory";

# If a download directory hasn't been specified then try to guess one
# but ask for confirmation first
guess_dir MODULES_DIR "modules" \
    "the directory to create android ndk modules in" "Modules directory";

function download_file ()
{
    local url="$1"; shift;
    local filename="$1"; shift;

    if test -f "$DOWNLOAD_DIR/$filename"; then
        echo "Skipping download of $filename because the file already exists";
        return 0;
    fi;

    case "$DOWNLOAD_PROG" in
	curl)
	    curl -o "$DOWNLOAD_DIR/$filename" "$url";
	    ;;
	*)
	    $DOWNLOAD_PROG -O "$DOWNLOAD_DIR/$filename" "$url";
	    ;;
    esac;

    if [ $? -ne 0 ]; then
	echo "Downloading ${url} failed.";
	exit 1;
    fi;
}

function git_clone ()
{
    local url="$1"; shift
    local commit="$1"; shift

    local name=${url##*/}
    name=${name%.git}

    pushd $BUILD_DIR &>/dev/null

    if test -d $name; then
	pushd $name &>/dev/null
	if ! `git log|grep -q "commit $commit"`; then
	    echo "Found existing $name clone not based on $commit"
	    exit 1
	fi
	popd &>/dev/null
    else
	git clone $url
	if [ $? -ne 0 ]; then
	    echo "Cloning ${url} failed."
	    exit 1
	fi

	pushd $name &>/dev/null
	git checkout -b cogl-android-sdk-build $commit
	if [ $? -ne 0 ]; then
	    echo "Checking out $commit failed"
	    exit 1
	fi
    fi

    if test -d $COGL_ANDROID_SDK_DIR/$name-patches; then
	for i in $COGL_ANDROID_SDK_DIR/$name-patches/*.patch
	do
	    git am $i
	done
    fi
    popd &>/dev/null

    popd &>/dev/null
}

# Try to guess a download program if none has been specified
if [ -z "$DOWNLOAD_PROG" ]; then
    # If no download program has been specified then check if wget or
    # curl exists
    #wget first, because my curl can't download libsdl...
    for x in wget curl; do
	if [ "`type -t $x`" != "" ]; then
	    DOWNLOAD_PROG="$x";
	    break;
	fi;
    done;

    if [ -z "$DOWNLOAD_PROG" ]; then
	echo "No DOWNLOAD_PROG was set and neither wget nor curl is ";
	echo "available.";
	exit 1;
    fi;
fi;

for package in $SOURCE_PACKAGES; do
    bn="${package##*/}";
    echo $bn
    download_file "$package" "$bn"
done;

download_file "$CONFIG_GUESS_URL" "config.guess";
download_file "$CONFIG_SUB_URL" "config.sub";

for repo_value in $GIT_REPOS; do
    repo=${repo_value%*@[a-z0-9]*}
    commit=${repo_value##*@}
    git_clone $repo $commit
done

cd $BUILD_DIR

if ! test -f $MODULES_DIR/libiconv/Android.mk; then
    tar -xvf $DOWNLOAD_DIR/libiconv-1.14.tar.gz
    pushd libiconv-1.14 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} .
    cp $DOWNLOAD_DIR/config.{sub,guess} ./build-aux
    cp $DOWNLOAD_DIR/config.{sub,guess} ./libcharset/build-aux
    gl_cv_header_working_stdint_h=yes ./configure --enable-static --disable-shared --host=arm-linux-androideabi --prefix=$MODULES_DIR/libiconv
    make install
    cp $COGL_ANDROID_SDK_DIR/libiconv-Android.mk $MODULES_DIR/libiconv/Android.mk
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/gettext/Android.mk; then
    tar -xvf $DOWNLOAD_DIR/gettext-0.18.tar.gz
    pushd gettext-0.18 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} ./build-aux/
    gl_cv_header_working_stdint_h=yes CPPFLAGS=-I$MODULES_DIR/libiconv/include LDFLAGS=-L$MODULES_DIR/libiconv/lib ./configure --host=arm-linux-androideabi --without-included-regex --disable-java --disable-openmp --without-libiconv-prefix --without-libintl-prefix --without-libglib-2.0-prefix --without-libcroco-0.6-prefix --with-included-libxml --without-libncurses-prefix --without-libtermcap-prefix --without-libcurses-prefix --without-libexpat-prefix --without-emacs --prefix=$MODULES_DIR/gettext
    make -C gettext-tools/intl install
    cp $COGL_ANDROID_SDK_DIR/gettext-Android.mk $MODULES_DIR/gettext/Android.mk
    popd &>/dev/null
fi

if ! test -d  $MODULES_DIR/libbind; then
    tar -xvf $DOWNLOAD_DIR/libbind-6.0.tar.gz
    pushd libbind-6.0 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} .
    ./configure --host=arm-linux-androideabi --with-randomdev=/dev/random --prefix=$MODULES_DIR/libbind && find ./ -iname '*.[ch]' -exec sed -i 's|include <sys/bitypes.h>|include <sys/types.h>|' {} \; && sed -i '\|#include <sys/param.h>| a#include <netinet/in.h>' ./include/arpa/inet.h
    #We don't want to build the tests...
    make subdirs timestamp install
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/glib/Android.mk; then
    tar -xvf $DOWNLOAD_DIR/glib-2.29.2.tar.bz2
    pushd glib-2.29.2 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} .
    for i in $COGL_ANDROID_SDK_DIR/glib-patches/*.patch; do patch -p1 <$i; done
    autoconf
    #note: PKG_CONFIG_LIBDIR is set to an invalid path so configure.ac doesn't find any system packages
    PKG_CONFIG_LIBDIR=/foo/bar glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=no ac_cv_func_posix_getgrgid_r=no CPPFLAGS="-I$MODULES_DIR/libbind/include/bind -I$MODULES_DIR/libiconv/include -I$MODULES_DIR/gettext/include" LDFLAGS="-L$MODULES_DIR/libbind/lib -L$MODULES_DIR/libiconv/lib -L$MODULES_DIR/gettext/lib" ./configure --host=arm-linux-androideabi --disable-shared --with-libiconv=gnu --prefix=$MODULES_DIR/glib
    make install
    rm -fr $MODULES_DIR/glib/bin
    rm -fr $MODULES_DIR/glib/share/gtk-doc
    cp $COGL_ANDROID_SDK_DIR/glib-Android.mk $MODULES_DIR/glib/Android.mk
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/libpng/Android.mk; then
    tar -xvf $DOWNLOAD_DIR/libpng-1.5.9.tar.xz
    pushd libpng-1.5.9 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} .
    ./configure --host=arm-linux-androideabi --prefix=$MODULES_DIR/libpng
    make install
    cp $COGL_ANDROID_SDK_DIR/libpng-Android.mk $MODULES_DIR/libpng/Android.mk
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/expat/Android.mk; then
    tar -xvf $DOWNLOAD_DIR/expat-2.0.1.tar.gz
    pushd expat-2.0.1 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} ./conftools
    ./configure --host=arm-linux-androideabi --prefix=$MODULES_DIR/expat
    make install
    cp $COGL_ANDROID_SDK_DIR/expat-Android.mk $MODULES_DIR/expat/Android.mk
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/freetype/Android.mk; then
    tar -xvf $DOWNLOAD_DIR/freetype-2.4.6.tar.bz2
    pushd freetype-2.4.6 &>/dev/null
    cp $DOWNLOAD_DIR/config.{sub,guess} ./builds/unix
    CFLAGS=-std=gnu99 ./configure --host=arm-linux-androideabi --prefix=$MODULES_DIR/freetype
    make install
    cp $COGL_ANDROID_SDK_DIR/freetype-Android.mk $MODULES_DIR/freetype/Android.mk
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/glib-android/Android.mk; then
    pushd glib-android &>/dev/null
    autoreconf -i -v
    cp $DOWNLOAD_DIR/config.{sub,guess} ./build/autotools
    PKG_CONFIG_PATH=$MODULES_DIR/glib/lib/pkgconfig ./configure --disable-shared --host=arm-linux-androideabi --prefix=$MODULES_DIR/glib-android
    make install
    cp $COGL_ANDROID_SDK_DIR/glib-android-Android.mk $MODULES_DIR/glib-android/Android.mk
    popd &>/dev/null
fi

if ! test -f $MODULES_DIR/cogl/Android.mk; then
    pushd cogl &>/dev/null
    NOCONFIGURE=1 ./autogen.sh
    cp $DOWNLOAD_DIR/config.{sub,guess} ./build
    CPPFLAGS="-I$MODULES_DIR/gettext/include" LDFLAGS="-L$MODULES_DIR/gettext/lib" PKG_CONFIG_LIBDIR=/foo/bar PKG_CONFIG_PATH=$MODULES_DIR/glib/lib/pkgconfig ./configure  --disable-shared --host=arm-linux-androideabi --prefix=$MODULES_DIR/cogl --disable-gles1 --enable-gles2 --enable-android-egl-platform=yes --disable-gl --enable-debug --disable-cairo --disable-cogl-pango
    make -i install
    cp $COGL_ANDROID_SDK_DIR/cogl-Android.mk $MODULES_DIR/cogl/Android.mk
    popd &>/dev/null
fi

if ! test -d $MODULES_DIR/samples; then
    cp -av $BUILD_DIR/cogl/examples/android $MODULES_DIR/samples
fi
