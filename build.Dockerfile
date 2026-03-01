# ============================
# Stage 1: Qt install
# ============================
FROM ubuntu:22.04 AS builder

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip curl wget unzip xz-utils git ca-certificates \
    && pip3 install aqtinstall \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN aqt install-qt linux desktop ${QT_VERSION} gcc_64 -O /opt/Qt \
    --modules qtwebsockets


# ============================
# Stage 2: Build + Test environment
# ============================
FROM ubuntu:22.04

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

# ---- 依存を1 RUNにまとめる ----
RUN apt-get update && apt-get install -y \
    build-essential cmake pkg-config patchelf wget git file \
    python3 python3-pip \
    \
    # Qt / X11 / Wayland ランタイム
    libgl1-mesa-dev libglu1-mesa-dev libgl1 libglx0 libopengl0 libglu1-mesa mesa-utils \
    libxkbcommon0 libxkbcommon-x11-0 libdbus-1-3 \
    libxcb1 libxcb-cursor0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-render-util0 libxcb-render0 libxcb-randr0 libxcb-shape0 \
    libxcb-xfixes0 libxcb-xinerama0 libxcb-xinput0 libxcb-xkb1 \
    libx11-6 libnss3 libasound2 \
    libwayland-client0 libwayland-cursor0 libwayland-egl1 libwayland-server0 wayland-protocols \
    \
    # Xvfb + WM + GUI automation
    xvfb x11-apps xauth \
    openbox fluxbox \
    xdotool wmctrl dbus-x11 \
    xserver-xorg-core xserver-xorg-video-dummy xfonts-base \
    \
    # PipeWire（本体 + Pulse + WirePlumber）
    pipewire pipewire-pulse wireplumber \
    \
    # PipeWire Python バインディング（←これが import pipewire を満たす）
    python3-pipewire \
    \
    # 画像処理 / OCR / 動画
    ffmpeg imagemagick tesseract-ocr \
    \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Python ライブラリ ----
RUN pip3 install \
    pytest pillow opencv-python websocket-client pyyaml numpy argcomplete

# ---- Qt をコピー ----
COPY --from=builder /opt/Qt /opt/Qt

ENV CMAKE_PREFIX_PATH="/opt/Qt/${QT_VERSION}/gcc_64"
ENV PATH="/opt/Qt/${QT_VERSION}/gcc_64/bin:${PATH}"

WORKDIR /workspace
CMD ["/bin/bash"]
