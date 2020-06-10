FROM debian:10 AS builder

RUN apt update && \
    apt dist-upgrade -y

RUN apt-get install -y g++ cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev git xorg-dev curl unzip

RUN mkdir -p $HOME/deps/skia && \
    cd $HOME/deps/skia && \
    curl -LvO https://github.com/aseprite/skia/releases/download/m81-b607b32047/Skia-Linux-Release-x64.zip && \
    unzip Skia-Linux-Release-x64.zip

RUN git clone --recursive https://github.com/aseprite/aseprite.git

RUN cd aseprite && \
    mkdir build && \
    cd build && \
    cmake \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DLAF_OS_BACKEND=skia \
      -DSKIA_DIR=$HOME/deps/skia \
      -DSKIA_LIBRARY_DIR=$HOME/deps/skia/out/Release-x64 \
      -G Ninja \
      .. && \
    ninja aseprite


FROM debian:10

RUN apt update && \
    apt dist-upgrade -y

RUN apt install -y libxcb1 xorg openbox xdm strace

RUN useradd --create-home aseprite
USER aseprite

WORKDIR /home/aseprite

COPY --from=builder aseprite/build/bin/aseprite aseprite.bin
RUN mkdir -p .config/aseprite
COPY --from=builder aseprite/data .config/aseprite/data
CMD ["./aseprite.bin"]
