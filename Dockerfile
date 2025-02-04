#
# Building process is based on https://gitlab.com/nvidia/container-images/opengl
#

#
# 1. Build cuda devel with opengl base
#
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 as cuda_devel_opengl_base

RUN apt-get update && apt-get install -y --no-install-recommends \
        libxau6 \
        libxdmcp6 \
        libxcb1 \
        libxext6 \
        libx11-6 && \
    rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
        ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
        ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# Required for non-glvnd setups.
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

#
# 2. Build cuda devel with opengl runtime
#
FROM cuda_devel_opengl_base as cuda_devel_opengl_runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
        libglvnd0 \
        libgl1 \
        libglx0 \
        libegl1 \
        libgles2 && \
    rm -rf /var/lib/apt/lists/*

COPY 10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

#
# 3. Build cuda devel with opengl devel
#
FROM cuda_devel_opengl_runtime as cuda_devel_opengl_devel

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        pkg-config \
        libglvnd-dev \
        libgl1-mesa-dev \
        libegl1-mesa-dev \
        libgles2-mesa-dev && \
    rm -rf /var/lib/apt/lists/*

#
# 4. Build final builder image
#
FROM cuda_devel_opengl_devel as builder

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

CMD ["ls"]
