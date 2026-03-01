# ============================
# Stage 1: Qt install
# ============================
FROM ubuntu:22.04 AS builder

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 python3-pip curl wget unzip xz-utils git ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install aqtinstall

RUN aqt install-qt linux desktop ${QT_VERSION} gcc_64 -O /opt/Qt \
    --modules qtwebsockets

# ============================
# Stage 2: Runtime environment
# ============================
FROM ubuntu:22.04

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    imagemagick \
    tesseract-ocr \
    ffmpeg \
    pipewire \
    pipewire-pulse \
    wireplumber \
    jq \
    libxkbcommon0 \
    libx11-6 \
    libxcb1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-render0 \
    libxcb-randr0 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-xinput0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libglu1-mesa \
    libgl1 \
    libglx0 \
    libopengl0 \
    mesa-utils \
    libnss3 \
    libasound2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Qt ランタイムのみコピー
COPY --from=builder /opt/Qt /opt/Qt

ENV PATH="/opt/Qt/${QT_VERSION}/gcc_64/bin:${PATH}"

WORKDIR /workspace
CMD ["/bin/bash"]
