# Copyright 2023 The MathWorks, Inc.

# Use lower case to specify the release, for example: ARG MATLAB_RELEASE=r2023b
ARG MATLAB_RELEASE=r2023b

FROM ubuntu:22.04

ARG MATLAB_RELEASE

# Install Polyspace Test dependencies
ENV DEBIAN_FRONTEND="noninteractive" TZ="Etc/UTC"
RUN apt-get update && apt-get install --no-install-recommends -y \
    libasound2 \
    libc6 \
    libcairo-gobject2 \
    libcairo2 \
    libcrypt1 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libgdk-pixbuf-2.0-0 \
    libglib2.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libgstreamer1.0-0 \
    libgtk-3-0 \
    libice6 \
    libnspr4 \
    libnss3 \
    libpam0g \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpangoft2-1.0-0 \
    libuuid1 \
    libwayland-client0 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxft2 \
    libxinerama1 \
    libxrandr2 \
    libxt6 \
    libxtst6 \
    libxxf86vm1 \
    locales \
    locales-all \
    zlib1g

# Uncomment the following line if you want to install GCC/G++
# RUN apt-get install --no-install-recommends --yes gcc g++

# Install mpm dependencies
RUN apt-get install --no-install-recommends --yes \
        wget \
        unzip \
        sudo \
        ca-certificates && \
    apt-get clean && apt-get autoremove

# Run mpm to install Polyspace Bug Finder and Code Prover Server in the target location
# and delete the mpm installation afterwards
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm && \ 
    chmod +x mpm && \
    ./mpm install \
        --release=${MATLAB_RELEASE} \
        --destination=/opt/matlab \
        --products Polyspace_Test && \
    rm -f mpm /tmp/mathworks_root.log && \
    ln -s /opt/matlab/polyspace/bin/polyspace* /usr/local/bin/

# Add "polyspace" user and grant sudo permission.
RUN adduser --shell /bin/bash --disabled-password --gecos "" polyspace && \
    echo "polyspace ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/polyspace && \
    chmod 0440 /etc/sudoers.d/polyspace

# One of the following 2 ways of configuring the license server to use must be
# uncommented.

ARG LICENSE_SERVER
# Specify the host and port of the machine that serves the network licenses 
# if you want to bind in the license info as an environment variable. This 
# is the preferred option for licensing. It is either possible to build with 
# something like --build-arg LICENSE_SERVER=27000@MyServerName, alternatively
# you could specify the license server directly using
#       ENV MLM_LICENSE_FILE=27000@flexlm-server-name
ENV MLM_LICENSE_FILE=$LICENSE_SERVER

# Alternatively you can put a license file into the container.
# You should fill this file out with the details of the license 
# server you want to use and uncomment the following line.
# COPY network.lic /opt/matlab/licenses/

# Set user and work directory
USER polyspace
WORKDIR /home/polyspace
CMD []
