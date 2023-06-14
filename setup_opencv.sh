#!/bin/bash
# Copyright 2019 The MediaPipe Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =========================================================================
#
# Script to build OpenCV from source code and modify the MediaPipe opencv config.
# Note that this script only has been tested on Debian 9 and Ubuntu 16.04.
#
# To have a full installation:
# $ cd <mediapipe root dir>
# $ sh ./setup_opencv.sh
#
# To only modify the mediapipe config for opencv:
# $ cd <mediapipe root dir>
# $ sh ./setup_opencv.sh config_only

set -e
if [ "$1" ] && [ "$1" != "config_only" ]
  then
    echo "Unknown input argument. Do you mean \"config_only\"?"
    exit 0
fi

opencv_build_file="$( cd "$(dirname "$0")" ; pwd -P )"/third_party/opencv_wasm.BUILD
workspace_file="$( cd "$(dirname "$0")" ; pwd -P )"/WORKSPACE
install_prefix="/home/joao/ext/opencv_lib"

if [ -z "$1" ]
  then
    echo "Installing OpenCV from source"
    if [[ -x "$(command -v apt)" ]]; then
      sudo apt update && sudo apt install build-essential git
      sudo apt install cmake ffmpeg libavformat-dev libdc1394-dev libgtk2.0-dev \
                       libjpeg-dev libpng-dev libswscale-dev libtbb2 libtbb-dev \
                       libtiff-dev
    elif [[ -x "$(command -v dnf)" ]]; then
      sudo dnf update && sudo dnf install cmake gcc gcc-c git
      sudo dnf install ffmpeg-devel libdc1394-devel gtk2-devel \
                       libjpeg-turbo-devel libpng-devel tbb-devel \
                       libtiff-devel
    fi
    rm -rf /tmp/build_opencv
    mkdir /tmp/build_opencv
    cd /tmp/build_opencv
    git clone https://github.com/opencv/opencv_contrib.git
    git clone https://github.com/opencv/opencv.git
    mkdir opencv/release
    cd opencv_contrib
    git checkout 4.x
    cd ../opencv
    git checkout 4.x
    cd release
    emcmake cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=${install_prefix} \
           -DPYTHON_DEFAULT_EXECUTABLE=/usr/bin/python \
           -DENABLE_PIC=FALSE \
	   -DCPU_BASELINE='' \
           -DCPU_DISPATCH='' \
           -DCV_TRACE=OFF \
           -DBUILD_SHARED_LIBS=OFF \
           -DWITH_1394=OFF \
           -DWITH_ADE=OFF \
           -DWITH_VTK=OFF \
           -DWITH_EIGEN=OFF \
           -DWITH_FFMPEG=OFF \
           -DWITH_GSTREAMER=OFF \
           -DWITH_GTK=OFF \
           -DWITH_GTK_2_X=OFF \
           -DWITH_IPP=OFF \
           -DWITH_JASPER=OFF \
           -DWITH_JPEG=OFF \
           -DWITH_WEBP=OFF \
           -DWITH_OPENEXR=OFF \
           -DWITH_OPENGL=OFF \
           -DWITH_OPENVX=OFF \
           -DWITH_OPENNI=OFF \
           -DWITH_OPENNI2=OFF \
           -DWITH_PNG=OFF \
           -DWITH_TBB=OFF \
           -DWITH_TIFF=OFF \
           -DWITH_V4L=OFF \
           -DWITH_OPENCL=OFF \
           -DWITH_OPENCL_SVM=OFF \
           -DWITH_OPENCLAMDFFT=OFF \
           -DWITH_OPENCLAMDBLAS=OFF \
           -DWITH_GPHOTO2=OFF \
           -DWITH_LAPACK=OFF \
           -DWITH_ITT=OFF \
           -DWITH_QUIRC=ON \
           -DBUILD_ZLIB=ON \
           -DBUILD_opencv_apps=OFF \
           -DBUILD_opencv_calib3d=ON \
           -DBUILD_opencv_dnn=ON \
           -DBUILD_opencv_features2d=ON \
           -DBUILD_opencv_flann=ON \
           -DBUILD_opencv_gapi=OFF \
           -DBUILD_opencv_ml=OFF \
           -DBUILD_opencv_photo=ON \
           -DBUILD_opencv_imgcodecs=ON \
           -DBUILD_opencv_shape=OFF \
           -DBUILD_opencv_videoio=ON \
           -DBUILD_opencv_videostab=OFF \
           -DBUILD_opencv_highgui=ON \
           -DBUILD_opencv_superres=OFF \
           -DBUILD_opencv_stitching=OFF \
           -DBUILD_opencv_java=OFF \
           -DBUILD_opencv_js=ON \
           -DBUILD_opencv_python2=OFF \
           -DBUILD_opencv_python3=OFF \
           -DBUILD_EXAMPLES=OFF \
           -DBUILD_PACKAGE=OFF \
           -DBUILD_TESTS=OFF \
           -DBUILD_PERF_TESTS=OFF \
           -DBUILD_DOCS=OFF \
           -DWITH_PTHREADS_PF=OFF \
           -DCV_ENABLE_INTRINSICS=ON \
           -DBUILD_WASM_INTRIN_TESTS=OFF \
           -DCMAKE_C_FLAGS='-s WASM=1 -s SINGLE_FILE=1 -s USE_PTHREADS=0 -msimd128 ' \
           -DCMAKE_CXX_FLAGS='-s WASM=1 -s SINGLE_FILE=1 -s USE_PTHREADS=0 -msimd128'
    emmake make -j 16
    sudo make install
    rm -rf /tmp/build_opencv
    echo "OpenCV has been built. You can find the header files and libraries in ${install_prefix}/include/opencv2/ and ${install_prefix}/lib"

    # https://github.com/cggos/dip_cvqt/issues/1#issuecomment-284103343
    sudo touch /etc/ld.so.conf.d/mp_opencv.conf
    sudo bash -c  "echo ${install_prefix}/lib >> /etc/ld.so.conf.d/mp_opencv.conf"
    sudo ldconfig -v
fi

# Modify the build file.
echo "Modifying MediaPipe opencv config"

sed -i "/linkopts/a \ \ \ \ \ \ \ \ \ \"-L${install_prefix}/lib\"," $opencv_build_file
wasm_opencv_config=$(grep -n 'wasm_opencv' $workspace_file | awk -F  ":" '{print $1}')
path_line=$((wasm_opencv_config + 2))
sed -i "$path_line d" $workspace_file
sed -i "$path_line i\    path = \"${install_prefix}\"," $workspace_file
echo "Done"
