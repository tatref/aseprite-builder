FROM debian:9 AS builder


RUN apt update && \
    apt dist-upgrade -y && \
    apt-get install -y g++ cmake ninja-build libx11-dev libxcursor-dev libgl1-mesa-dev libfontconfig1-dev git

RUN mkdir $HOME/deps && \
    cd $HOME/deps && \
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git && \
    git clone -b aseprite-m71 https://github.com/aseprite/skia.git

RUN apt install -y python && \
    cd $HOME/deps && \
    export PATH="${PWD}/depot_tools:${PATH}" && \
    cd skia && \
    python tools/git-sync-deps && \
    gn gen out/Release --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false" && \
    ninja -C out/Release skia

RUN git clone --recursive https://github.com/aseprite/aseprite.git

RUN cd aseprite && \
    mkdir build && \
    cd build && \
    cmake \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DLAF_OS_BACKEND=skia \
      -DSKIA_DIR=$HOME/deps/skia \
      -DSKIA_OUT_DIR=$HOME/deps/skia/out/Release \
      -G Ninja \
      .. && \
    ninja aseprite


FROM debian:10

RUN apt update && \
    apt dist-upgrade -y

RUN apt install -y libxcb1 xorg openbox xdm
RUN apt install -y strace

#RUN useradd --create-home aseprite
#USER aseprite
WORKDIR /root
RUN mkdir -p .config/aseprite

COPY --from=builder aseprite/build/bin/aseprite aseprite.bin
COPY --from=builder aseprite/data .config/aseprite/data
CMD ["./aseprite.bin"]
