# Dockerfile for Minix version 3.3.0

# --- Base image --- #
FROM debian:10.9 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Arguments for Minix download paths and version
ARG MINIX_MIRROR="http://download.minix3.org/iso/minix_R3.3.0-588a35b.iso.bz2"
ARG MINIX_VERSION="3.3.0"

# Minix source code path
# Note: The master branch is used here, but it may not be stable. Appropriate patches are done in this Dockerfile.
# You can specify a specific commit or branch if needed.
ARG MINIX_SRC="https://github.com/Stichting-MINIX-Research-Foundation/minix/archive/refs/heads/master.zip"

# Dependency installs + clean up
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 \
    qemu-system \
    qemu-utils \
    ssh \
    wget \
    curl \
    bzip2 \
    unzip \
    zip \
    build-essential \
    git \
#   zlibc       # zlibc is not available in Ubuntu 24.04
    zlib1g \
    zlib1g-dev \
    make \
    gcc \
    g++ \
    gcc-multilib \
    g++-multilib \
    gdb \
    gdb-multiarch \
    libncurses-dev \
    xz-utils \
    nano \
    sudo
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*


ARG USER="minix"
ARG USER_HOME="/home/${USER}"

# Setup user "minix"
RUN useradd --create-home --home-dir "${USER_HOME}" --shell=/bin/bash --user-group "${USER}" --groups sudo && \
    chown "${USER}:${USER}" "${USER_HOME}" && \
    echo "${USER}:minix" | chpasswd

# Copy scripts into WORKDIR
COPY run.sh ${USER_HOME}/run.sh
COPY setup.sh ${USER_HOME}/setup.sh
RUN chmod -R +x ${USER_HOME}/run.sh ${USER_HOME}/setup.sh

# Change ownership of scripts to user
RUN chown -R ${USER}:${USER} ${USER_HOME}/run.sh ${USER_HOME}/setup.sh

# Set user and working directory
USER ${USER}
WORKDIR ${USER_HOME}

# Get Minix ISO image & Minix source files (source set in MINIX_SRC)
RUN wget -q ${MINIX_MIRROR} -O "minix_v${MINIX_VERSION}.iso.bz2" && \
    bunzip2 "minix_v${MINIX_VERSION}.iso.bz2" && \
    wget --no-check-certificate ${MINIX_SRC} -O "minix_src.zip" && \
    unzip -qq "minix_src.zip" && \
    rm "minix_src.zip"

# ----------------#
# --   PATCH   -- #
# Set root user for patching
USER root

# Patch this issue: https://github.com/Stichting-MINIX-Research-Foundation/minix/pull/301
COPY patches/valuemap_hasmd.patch ${USER_HOME}/patches/valuemap_hasmd.patch
RUN sudo chown -R ${USER}:${USER} ${USER_HOME}/patches
RUN patch -p1 -d ${USER_HOME}/minix-master < ${USER_HOME}/patches/valuemap_hasmd.patch

# Set user back to minix
USER ${USER}
# -- END PATCH -- #
# ----------------#

CMD ["/bin/bash"]
