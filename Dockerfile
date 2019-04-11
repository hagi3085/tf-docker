# docker上でtensorflow c++を実行できる環境の作成
# 基盤のdocker
FROM nvidia/cuda:9.0-cudnn7-devel
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

# ファイルのダウンロード
RUN mkdir /root/tmp
# bazel
RUN mkdir /root/tmp/bazel
WORKDIR /root/tmp/bazel
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.16.1/bazel_0.16.1-linux-x86_64.deb \
    && wget https://github.com/bazelbuild/bazel/releases/download/0.16.1/bazel-0.16.1-installer-linux-x86_64.sh \
    && apt -f install \
    && dpkg -i bazel_0.16.1-linux-x86_64.deb \
    && chmod +x bazel-0.16.1-installer-linux-x86_64.sh && ./bazel-0.16.1-installer-linux-x86_64.sh --user

# tensorflow
WORKDIR /root/tmp
RUN git clone https://github.com/tensorflow/tensorflow.git
WORKDIR /root/tmp/tensorflow
RUN git checkout r1.12
ARG TENSORFLOW_VERSION=1.12.0
ARG TENSORFLOW_DEVICE=gpu
ARG TENSORFLOW_APPEND=_gpu

ENV PYTHON_BIN_PATH=/usr/bin/python3
ENV PYTHON_LIB_PATH=/usr/lib/python3.5/dist-packages
ENV CC_OPT_FLAGS="--config=opt"
ENV TF_NEED_IGNITE=0
ENV TF_NEED_OPENCL_SYCL=0
ENV TF_NEED_ROCM=0
ENV TF_ENABLE_XLA=0
ENV TF_NEED_COMPUTECPP=0
ENV TF_NEED_CUDA=1
ENV TF_CUDA_CLANG=0
ENV TF_NEED_TENSORRT=0
ENV TF_NEED_MPI=0
ENV TF_NCCL_VERSION=1.3
ENV TF_SET_ANDROID_WORKSPACE=0
ENV GCC_HOST_COMPILER_PATH=/usr/bin/gcc
ENV HOST_CXX_COMPILER=/usr/bin/g++
ENV CUDA_TOOLKIT_PATH=/usr/local/cuda-9.0
ENV CUDNN_INSTALL_PATH=/usr
ENV TF_CUDA_COMPUTE_CAPABILITIES="3.5,6.1,7.0" 
ENV LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64:/usr/local/cuda-9.0/extras/CUPTI/lib64:/usr/local/cuda-9.0/lib64/stubs
ENV CUDA_PATH=/usr/local/cuda-9.0
RUN ./configure
RUN bazel build -c opt --config=cuda //tensorflow:libtensorflow_cc.so \
    && bazel build -c opt --config=cuda //tensorflow:libtensorflow.so \
    && ln -s /root/tmp/tensorflow/bazel-bin/tensorflow/libtensorflow.so /usr/local/lib/libtensorflow.so \
    && ln -s /root/tmp/tensorflow/bazel-bin/tensorflow/libtensorflow_cc.so /usr/local/lib/libtensorflow_cc.so \
    && ln -s /root/tmp/tensorflow/bazel-bin/tensorflow/libtensorflow_framework.so /usr/local/lib/libtensorflow_framework.so \
    && wget https://raw.githubusercontent.com/hagi3085/tf_setInclude/master/collect_headers.sh \
    && chmod +x collect_headers.sh && ./collect_headers.sh