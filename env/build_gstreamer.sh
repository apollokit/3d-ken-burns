#!/bin/bash
# notes
# - for nvcodec, need to install nvidia driver and cuda toolkit first. See https://confluence.vincilab.co/display/~kkennedy/2020/10/29/2020-10-29 for tips
set -ex

SCRIPT_DIR=$(dirname $(realpath $0))
BUILD_DIR=~/.config/vinci/gstreamer_build
VC="/opt/vc/lib/pkgconfig"
GST_VERSION="tags/1.18.0"

mkdir -p $BUILD_DIR

# Check if we are a rpi
if grep -q BCM27 /proc/cpuinfo; then
    echo "RPI BUILD!"
    RPI="1"
fi

# Create a log file of the build as well as displaying the build on the tty as it runs
exec > >(tee build_gstreamer.log)
exec 2>&1

# While working on this I ended up doing an rpi-update 
# (as a potential solutuion posed here
# https://github.com/mpv-player/mpv-build/issues/84)
# This resulted in fw version e530832e9058ab73b0d45457aea06f0ea62a08a8
# which is what this script was developed on.

# Install dependencies
sudo apt-get -y -q install \
    build-essential meson flex bison git python3 \
    libglfw3-dev libgles2-mesa-dev \
    libx265-dev libxml2-dev zlib1g-dev libglib2.0-dev libasound2-dev \
    libgudev-1.0-dev libxt-dev libvorbis-dev libcdparanoia-dev \
    libpango1.0-dev libtheora-dev libvisual-0.4-dev iso-codes \
    libgtk-3-dev libraw1394-dev libiec61883-dev libavc1394-dev \
    libv4l-dev libcairo2-dev libcaca-dev libspeex-dev libpng-dev \
    libshout3-dev libjpeg-dev libaa1-dev libflac-dev libdv4-dev \
    libtag1-dev libwavpack-dev libpulse-dev libsoup2.4-dev libbz2-dev \
    libcdaudio-dev libdc1394-22-dev ladspa-sdk libass-dev \
    libcurl4-gnutls-dev libdca-dev libdvdnav-dev \
    libexempi-dev libexif-dev libfaad-dev libgme-dev libgsm1-dev \
    libiptcdata0-dev libkate-dev libmimic-dev libmms-dev \
    libmodplug-dev libmpcdec-dev libofa0-dev libopus-dev \
    librsvg2-dev librtmp-dev  \
    libsndfile1-dev libsoundtouch-dev libspandsp-dev libx11-dev \
    libxvidcore-dev libzbar-dev libzvbi-dev liba52-0.7.4-dev \
    libcdio-dev libdvdread-dev libmad0-dev libmp3lame-dev \
    libmpeg2-4-dev libopencore-amrnb-dev libopencore-amrwb-dev \
    libsidplay1-dev libtwolame-dev libx264-dev libusb-1.0 \
    yasm python3-dev libgirepository1.0-dev liblapack-dev


# Get gst-build repo
cd "${BUILD_DIR}"
[ ! -d gst-build ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-build

# Checkout correct branch
cd "${BUILD_DIR}/gst-build"
git checkout $GST_VERSION

# Configure
if [[ $RPI -eq 1 ]]; then
    # Fix some package config paths to make linking work right
    cd "${VC}"
    if [ ! -f "${VC}/egl.pc" ]; then
      sudo ln -s brcmegl.pc egl.pc
    fi
    if [ ! -f "${VC}/glesv2.pc" ]; then
      sudo ln -s brcmglesv2.pc glesv2.pc
    fi

    # Some rpi specific libs
    sudo apt-get -y -q install \
        libschroedinger-dev libslv2-dev libatlas-base-dev

    # get back into the build directory for the fun
    cd "${BUILD_DIR}/gst-build"

    PKG_CONFIG_PATH="${VC}" meson build \
      -D gst-plugins-base:gl_api=gles2 \
      -D gst-plugins-base:gl_platform=egl \
      -D gst-plugins-base:gl_winsys=dispmanx \
      -D gst-plugins-base:gles2_module_name=/opt/vc/lib/libbrcmGLESv2.so \
      -D gst-plugins-base:egl_module_name=/opt/vc/lib/libbrcmEGL.so \
      -D bad=enabled \
      -D omx=enabled \
      -D rtsp-server=enabled \
      -D gst-omx:header_path=/opt/vc/include/IL \
      -D gst-omx:target=rpi \
      || exit -1
else
    meson build \
      -D bad=enabled \
      -D vaapi=enabled \
      -D rtsp-server=enabled \
      -D gst-plugins-bad:nvcodec=enabled \
      || exit -1
fi

# Build
ninja -C build || exit -1

# Now the build will be in $BUILD_DIR/gst-build/build 
