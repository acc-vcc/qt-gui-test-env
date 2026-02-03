# ============================
# Stage 1: Qt & noVNC のビルドステージ
# ============================
FROM ubuntu:22.04 AS builder

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    wget \
    unzip \
    xz-utils \
    git \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# aqtinstall
RUN pip3 install aqtinstall

# Qt install
RUN aqt install-qt linux desktop ${QT_VERSION} gcc_64 -O /opt/Qt

# noVNC + websockify
RUN mkdir -p /opt/novnc && \
    git clone --depth 1 https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone --depth 1 https://github.com/novnc/websockify.git /opt/novnc/utils/websockify

# ============================
# Stage 2: Runtime (最小構成 + fluxbox) ステージ
# ============================
FROM ubuntu:22.04

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    imagemagick \
    python3 \
    jq \
    libxkbcommon0 \
    libx11-6 \
    libxcb1 \
    libxcb-render0 \
    libxcb-shape0 \
    libxcb-xfixes0 \
    libglu1-mesa \
    libgl1 \
    libnss3 \
    libasound2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Qt + noVNC を丸ごとコピー
COPY --from=builder /opt /opt

# Qt のパス
ENV PATH="/opt/Qt/${QT_VERSION}/gcc_64/bin:${PATH}"

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
