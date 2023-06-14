FROM ghcr.io/rancher/elemental-toolkit/elemental-cli:v0.10.7 AS elemental

FROM opensuse/leap:15.4

# Install kernel, systemd, dracut, grub2 and other required tools
RUN zypper --non-interactive install -- \
      kernel-default systemd dracut grub2 grub2-x86_64-efi shim \
      parted gptfdisk e2fsprogs dosfstools mtools xorriso squashfs \
      device-mapper haveged NetworkManager timezone  findutils \
      openssh-server openssh-clients rsync findutils lvm2 tar gzip \
      vim which less sudo sed

ARG K3S_VERSION=v1.24.14+k3s1
ARG ARCH=amd64
ENV ARCH=${ARCH}

# Create non FHS paths
RUN mkdir -p /oem /system /etc/elemental/config.d /etc/k3s
RUN mkdir -p /usr/libexec && touch /usr/libexec/.keep

# Install elemental client
COPY --from=elemental /install-root /
COPY --from=elemental /usr/bin/elemental /usr/bin/elemental

# Install k3s server/agent
ENV INSTALL_K3S_VERSION=${K3S_VERSION}
RUN curl -sfL https://get.k3s.io > installer.sh && \
    INSTALL_K3S_BIN_DIR="/etc/k3s" INSTALL_K3S_SKIP_START="true" INSTALL_K3S_SKIP_ENABLE="true" sh installer.sh && \
    INSTALL_K3S_BIN_DIR="/etc/k3s" INSTALL_K3S_SKIP_START="true" INSTALL_K3S_SKIP_ENABLE="true" sh installer.sh agent && \
    rm -rf installer.sh

# Copy cloud-init default configuration
COPY cloud-init.yaml /system/oem/

# Enable cloud-init services
RUN systemctl enable cos-setup-rootfs.service && \
    systemctl enable cos-setup-initramfs.service && \
    systemctl enable cos-setup-reconcile.timer && \
    systemctl enable cos-setup-fs.service && \
    systemctl enable cos-setup-boot.service && \
    systemctl enable cos-setup-network.service

# Enable essential services
RUN systemctl enable NetworkManager.service

# Enable /tmp to be on tmpfs
RUN cp /usr/share/systemd/tmp.mount /etc/systemd/system

# Generate initrd with required elemental services
RUN dracut -f --regenerate-all

# Update os-release file with some metadata
RUN echo IMAGE_REPO=\"${REPO}\"             >> /etc/os-release && \
    echo IMAGE_TAG=\"${VERSION}\"           >> /etc/os-release && \
    echo IMAGE=\"${REPO}:${VERSION}\"       >> /etc/os-release && \
    echo TIMESTAMP="`date +'%Y%m%d%H%M%S'`" >> /etc/os-release

# Good for validation after the build
CMD /bin/bash
