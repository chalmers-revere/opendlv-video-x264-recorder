# Copyright (C) 2022  Christian Berger
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Part to build opendlv-video-x264-recorder.
FROM alpine:3.15 as builder
MAINTAINER Christian Berger "christian.berger@gu.se"

RUN apk update && \
    apk --no-cache add \
        bash \
        cmake \
        g++ \
        git \
        make \
        nasm
RUN cd tmp && \
    git clone --depth 1 http://git.videolan.org/git/x264.git && \
    cd x264 && \
    ./configure --disable-cli \
                --disable-opencl \
                --disable-gpl \
                --disable-avs \
                --disable-swscale \
                --disable-lavf \
                --disable-ffms \
                --disable-gpac \
                --disable-lsmash \
                --enable-pic \
                --enable-static \
                --enable-strip \
                --prefix=/usr && \
    make -j2 && make install
ADD . /opt/sources
WORKDIR /opt/sources
RUN mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/tmp .. && \
    make && make install


# Part to deploy opendlv-video-x264-recorder.
FROM alpine:3.15
MAINTAINER Christian Berger "christian.berger@gu.se"

WORKDIR /usr/bin
COPY --from=builder /tmp/bin/opendlv-video-x264-recorder .
ENTRYPOINT ["/usr/bin/opendlv-video-x264-recorder"]
