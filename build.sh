unpack the r7 ndk somewhere
build/tools/make-standalone-toolchain.sh --platform=android-9 --install-dir=/home/bob/local/android-toolchain

export GNOME_ANDROID_SRC_DIR=/home/bob/var/platforms/android/src
export GNOME_ANDROID_PACKAGE_DIR=/home/bob/var/platforms/android/packages

cd $GNOME_ANDROID_SRC_DIR

wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar -xvf libiconv-1.14.tar.gz
cd libiconv-1.14
cp ../config.{sub,guess} .
cp ../config.{sub,guess} ./build-aux
cp ../config.{sub,guess} ./libcharset/build-aux
gl_cv_header_working_stdint_h=yes ./configure --enable-static --disable-shared --host=arm-linux-androideabi --prefix=$GNOME_ANDROID_PACKAGE_DIR/libiconv
make install

wget http://ftp.gnu.org/gnu/gettext/gettext-0.18.tar.gz
tar -xvf gettext-0.18.tar.gz
cd gettext-0.18
cp ../config.{sub,guess} ./build-aux/
gl_cv_header_working_stdint_h=yes CPPFLAGS=-I$GNOME_ANDROID_PACKAGE_DIR/libiconv/include LDFLAGS=-L$GNOME_ANDROID_PACKAGE_DIR/libiconv/lib ./configure --host=arm-linux-androideabi --without-included-regex --disable-java --disable-openmp --without-libiconv-prefix --without-libintl-prefix --without-libglib-2.0-prefix --without-libcroco-0.6-prefix --with-included-libxml --without-libncurses-prefix --without-libtermcap-prefix --without-libcurses-prefix --without-libexpat-prefix --without-emacs --prefix=$GNOME_ANDROID_PACKAGE_DIR/gettext
make -C gettext-tools/intl install

wget ftp://ftp.isc.org/isc/libbind/6.0/libbind-6.0.tar.gz
tar -xvf libbind-6.0.tar.gz
cd libbind-6.0
cp ../config.{sub,guess} .
./configure --host=arm-linux-androideabi --with-randomdev=/dev/random --prefix=$GNOME_ANDROID_PACKAGE_DIR/libbind && find ./ -iname '*.[ch]' -exec sed -i 's|include <sys/bitypes.h>|include <sys/types.h>|' {} \; && sed -i '\|#include <sys/param.h>| a#include <netinet/in.h>' ./include/arpa/inet.h
#We don't want to build the tests...
make subdirs timestamp

wget http://ftp.acc.umu.se/pub/GNOME/sources/glib/2.29/glib-2.29.2.tar.bz2
tar -xvf glib-2.29.2.tar.bz2
cd glib-2.29.2
cp ../config.{sub,guess} .
for i in `ls ../glib-patches`; do patch -p1 <../glib-patches/$i; done
autoconf
#note: PKG_CONFIG_LIBDIR is set to an invalid path so configure.ac doesn't find any system packages
PKG_CONFIG_LIBDIR=/foo/bar glib_cv_stack_grows=no glib_cv_uscore=no ac_cv_func_posix_getpwuid_r=no ac_cv_func_posix_getgrgid_r=no CPPFLAGS="-I$GNOME_ANDROID_PACKAGE_DIR/libbind/include/bind -I$GNOME_ANDROID_PACKAGE_DIR/libiconv/include -I$GNOME_ANDROID_PACKAGE_DIR/gettext/include" LDFLAGS="-L$GNOME_ANDROID_PACKAGE_DIR/libbind/lib -L$GNOME_ANDROID_PACKAGE_DIR/libiconv/lib -L$GNOME_ANDROID_PACKAGE_DIR/gettext/lib" ./configure --host=arm-linux-androideabi --disable-shared --with-libiconv=gnu --prefix=$GNOME_ANDROID_PACKAGE_DIR/glib
make install

wget ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.4.tar.xz
tar -xvf libpng-1.5.4.tar.xz
cd libpng-1.5.4
cp ../config.{sub,guess} .
./configure --host=arm-linux-androideabi --prefix=$GNOME_ANDROID_PACKAGE_DIR/libpng
make install

wget http://sourceforge.net/projects/expat/files/expat/2.0.1/expat-2.0.1.tar.gz/download
tar -xvf expat-2.0.1.tar.gz
cd expat-2.0.1
cp ../config.{sub,guess} ./conftools
./configure --host=arm-linux-androideabi --prefix=$GNOME_ANDROID_PACKAGE_DIR/expat
make install

wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.6.tar.bz2
tar -xvf freetype-2.4.6.tar.bz2
cd freetype-2.4.6
cp ../config.{sub,guess} ./builds/unix
CFLAGS=-std=gnu99 ./configure --host=arm-linux-androideabi --prefix=$GNOME_ANDROID_PACKAGE_DIR/freetype
make install

git clone https://github.com/dlespiau/glib-android.git
autoreconf -i -v
cp ../config.{sub,guess} ./build/autotools
PKG_CONFIG_PATH=$GNOME_ANDROID_PACKAGE_DIR/glib/lib/pkgconfig ./configure --disable-shared --host=arm-linux-androideabi --prefix=$GNOME_ANDROID_PACKAGE_DIR/glib-android
make install

wget http://ftp.acc.umu.se/pub/GNOME/sources/cogl/1.7/cogl-1.7.6.tar.bz2
tar -xvf cogl-1.7.6.tar.bz2
cd cogl-1.7.6
cp ../config.{sub,guess} ./build
CPPFLAGS="-I$GNOME_ANDROID_PACKAGE_DIR/gettext/include" LDFLAGS="-L$GNOME_ANDROID_PACKAGE_DIR/gettext/lib" PKG_CONFIG_LIBDIR=/foo/bar PKG_CONFIG_PATH=$GNOME_ANDROID_PACKAGE_DIR/glib/lib/pkgconfig ./configure --enable-static --host=arm-linux-androideabi --prefix=$GNOME_ANDROID_PACKAGE_DIR/cogl --enable-gles1 --enable-android-egl-platform=yes --disable-gl --enable-debug --disable-cairo --disable-cogl-pango
make -i install
