FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso dosfstools squashfs-tools libisoburn mtools sed && \
    pacman -Scc --noconfirm

WORKDIR /workspace
ENTRYPOINT ["/workspace/scripts/build-iso.sh"]
