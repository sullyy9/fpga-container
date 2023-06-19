FROM archlinux:latest

# Install basic programs and custom glibc
RUN pacman --noconfirm -Syu && \
    pacman --noconfirm -S \
    git \
    gcc \
    npm \
    sudo \
    wget \
    make \
    yosys \
    unzip \
    which \
    ctags \
    python \
    python-pip \
    openocd \
    gtkwave \
    usbutils \
    verilator && \
    pacman --noconfirm -Scc

RUN pip install --break-system-packages \
    teroshdl \
    cocotb \
    cocotb-test \
    pytest \
    ruff \
    black \
    pylance \
    numpy \
    opencv-python

# Install Verible.
ARG VERIBLE_URL="https://github.com/chipsalliance/verible/releases/download/v0.0-3051-ga1534abb/verible-v0.0-3051-ga1534abb-Ubuntu-22.04-jammy-x86_64.tar.gz"
RUN wget -qO- $VERIBLE_URL | tar xvz -C /tmp/ && \
    cp /tmp/verible*/bin/* /usr/bin/ && \
    rm -r /tmp/verible*

COPY 60-openocd.rules /etc/udev/rules.d/
RUN /lib/systemd/systemd-udevd --daemon && \
    udevadm trigger && \ 
    udevadm control --reload-rules || echo "done"

# Setup default user
ENV USER=developer
RUN useradd --create-home -s /bin/bash -m $USER && \
    echo "$USER:archlinux" | chpasswd && \
    usermod -aG wheel $USER && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/$USER
USER $USER