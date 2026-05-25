# Uses monkeyx/retro_builder:arm64 as base image
FROM monkeyx/retro_builder:arm64

# Install QEMU for cross-platform emulation.
# The base image may include a stale Kitware apt source key, so remove that
# source list before apt-get update to avoid NO_PUBKEY build failures.
RUN rm -f /etc/apt/sources.list.d/kitware.list \
    /etc/apt/sources.list.d/archive_uri-https_apt_kitware_com_ubuntu-focal.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python3 -m pip install -r requirements.txt

VOLUME /root/workspace
WORKDIR /root/workspace

# Starting the container with Bash
CMD ["/bin/bash"]