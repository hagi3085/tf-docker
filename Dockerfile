# docker上でtensorflow c++を実行できる環境の作成
# 基盤のdocker
FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
# 作成ユーザー
MAINTAINER hagi3085
# 実行コマンド
# install
RUN apt update && apt -y upgrade \
    && apt install -y pkg-config zip g++ zlib1g-dev unzip python bash-completion \
    && apt install -y git vim curl wget swig llvm software-properties-common openjdk-8-jdk \
    && apt update && apt -y upgrade \
    && apt install -y python-dev python-numpy python-pip python-wheel \
    && apt install -y python3-dev python3-numpy python3-pip python3-wheel \
    && apt update && apt -y upgrade \
    && apt -f install \
    && ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1

# パッケージのインストール(ディスプレイ表示用)
RUN apt install -y libssl-dev libbz2-dev libsqlite3-dev libreadline-dev zlib1g-dev libasound2-dev \
    && apt install -y libxss1 libxtst6 gdebi

# ファイルのダウンロード
RUN mkdir /root/tmp
# bazel
RUN mkdir /root/tmp/bazel
WORKDIR /root/tmp/bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.16.1/bazel_0.16.1-linux-x86_64.deb \
    && wget https://github.com/bazelbuild/bazel/releases/download/0.16.1/bazel-0.16.1-installer-linux-x86_64.sh \
    && apt -f install \
    && dpkg -i bazel_0.16.1-linux-x86_64.deb \
    && chmod +x bazel-0.16.1-installer-linux-x86_64.sh && ./bazel-0.16.1-installer-linux-x86_64.sh --user \
    && rm bazel_0.16.1-linux-x86_64.deb \
    && rm bazel-0.16.1-installer-linux-x86_64.sh

# tensorflow
WORKDIR /root/tmp
RUN git clone https://github.com/tensorflow/tensorflow.git
WORKDIR /root/tmp/tensorflow
RUN git checkout r1.12
ARG TENSORFLOW_VERSION=1.12.3
ARG TENSORFLOW_DEVICE=gpu
ARG TENSORFLOW_APPEND=_gpu


# boostのインストール
WORKDIR /root/tmp/
RUN git clone --recursive https://github.com/boostorg/boost.git \
    && cd boost \
    && ./bootstrap.sh \
    && ./b2 toolset=gcc --prefix=/usr/local -j8 \
    && ./b2 install
RUN echo 'export INCLUDE_PATH=$INCLUDE_PATH:/root/tmp/boost' >> ~/.bashrc \
    && echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/tmp/boost/stage/lib' >> ~/.bashrc 

# python版tensorflowのインストール
RUN pip3 install tensorflow-gpu==1.12.3 keras==2.1.6

# opencv 
# RUN mkdir /root/tmp/
RUN git clone https://github.com/opencv/opencv.git
WORKDIR /root/tmp/opencv
RUN mkdir ./build && apt install -y cmake
WORKDIR /root/tmp/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_GENERATE_PKGCONFIG=ON ..  \
    && make -j8 \
    && make install \
    && ldconfig



ENV PYTHON_BIN_PATH=/usr/bin/python3 \
    PYTHON_LIB_PATH=/usr/lib/python3.5/dist-packages \
    CC_OPT_FLAGS="--config=opt" \
    TF_NEED_IGNITE=0 \
    TF_NEED_OPENCL_SYCL=0 \
    TF_NEED_ROCM=0 \
    TF_ENABLE_XLA=0 \
    TF_NEED_COMPUTECPP=0 \
    TF_NEED_CUDA=1 \
    TF_CUDA_CLANG=0 \
    TF_NEED_TENSORRT=0 \
    TF_NEED_MPI=0 \
    TF_NCCL_VERSION=1.3 \
    TF_SET_ANDROID_WORKSPACE=0 \
    GCC_HOST_COMPILER_PATH=/usr/bin/gcc \
    HOST_CXX_COMPILER=/usr/bin/g++ \
    CUDA_TOOLKIT_PATH=/usr/local/cuda-9.2 \
    CUDNN_INSTALL_PATH=/usr \
    TF_CUDA_COMPUTE_CAPABILITIES="6.1,7.0,7.5"  \
    LD_LIBRARY_PATH=/usr/local/cuda-9.2/lib64:/usr/local/cuda-9.2/extras/CUPTI/lib64:/usr/local/cuda-9.2/lib64/stubs \
    CUDA_PATH=/usr/local/cuda-9.2 \
    TF_CUDA_VERSION=9.2

WORKDIR /root/tmp/tensorflow
RUN ./configure \
    && bazel build -c opt --config=cuda //tensorflow:libtensorflow_cc.so \
    && bazel build -c opt --config=cuda //tensorflow:libtensorflow.so \
    && ln -s /root/tmp/tensorflow/bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/libtensorflow.so \
    && ln -s /root/tmp/tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so /usr/local/lib/libtensorflow_cc.so \
    && ln -s /root/tmp/tensorflow/bazel-bin/tensorflow/libtensorflow_framework.so /usr/local/lib/libtensorflow_framework.so \
    && wget https://raw.githubusercontent.com/hagi3085/tf_setInclude/master/collect_headers.sh \
    && chmod +x collect_headers.sh && ./collect_headers.sh \
    && rm collect_headers.sh

WORKDIR /home
