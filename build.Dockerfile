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

RUN aqt install-qt linux desktop ${QT_VERSION} gcc_64 -O /opt/Qt

# ============================
# Stage 2: Build environment
# ============================
FROM ubuntu:22.04

ARG QT_VERSION=6.6.1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    patchelf \
    wget \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Qt 開発環境をコピー
COPY --from=builder /opt/Qt /opt/Qt

# Qt の CMake パス
ENV CMAKE_PREFIX_PATH="/opt/Qt/${QT_VERSION}/gcc_64"
ENV PATH="/opt/Qt/${QT_VERSION}/gcc_64/bin:${PATH}"

WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
CMD ["-c"]
