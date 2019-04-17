#!/bin/bash -eu
# -*- coding: utf-8 -*-

HEADER_DIR=/root/tensorflow/include

if [ ! -e $HEADER_DIR ];
then
    mkdir -p $HEADER_DIR
fi

find tensorflow/core -follow -type f -name "*.h" -exec cp --parents {} $HEADER_DIR \;
find tensorflow/cc   -follow -type f -name "*.h" -exec cp --parents {} $HEADER_DIR \;
find tensorflow/c    -follow -type f -name "*.h" -exec cp --parents {} $HEADER_DIR \;

find third_party/eigen3 -follow -type f -exec cp --parents {} $HEADER_DIR \;

pushd bazel-genfiles
find tensorflow -follow -type f -name "*.h" -exec cp --parents {} $HEADER_DIR \;
popd

pushd bazel-tensorflow/external/protobuf_archive/src
find google -follow -type f -name "*.h" -exec cp --parents {} $HEADER_DIR \;
popd

pushd bazel-tensorflow/external/eigen_archive
find Eigen       -follow -type f -exec cp --parents {} $HEADER_DIR \;
find unsupported -follow -type f -exec cp --parents {} $HEADER_DIR \;
popd

pushd bazel-tensorflow/external
find com_google_absl -follow -type f -name "*.h" -exec cp --parents {} $HEADER_DIR \;
popd

# setting pkg-config
PC_DIR=/usr/local/lib/pkgconfig
if [ ! -e $PC_DIR ];
then
    mkdir -p $PC_DIR
fi

{
  echo "# Package Information for pkg-config"

  echo "prefix=/usr/local"
  echo 'exec_prefix=${prefix}'
  echo 'libdir=${exec_prefix}/lib'
  echo "includedir=/root/tensorflow/include/"


  echo "Name: tensorflow"
  echo "Version: 1.12"
  echo "Description: tensorflow Library"
  echo 'Libs: -L${exec_prefix}/lib -L/usr/local/lib -ltensorflow_cc -ltensorflow_framework -std=c++11'
  echo "Libs.private: -lcublas -lcufft -L-L/usr/local/cuda -llib64"
  echo 'Cflags: -I${includedir} -I${includedir}com_google_absl'
} > /usr/local/lib/pkgconfig/tensorflow.pc

