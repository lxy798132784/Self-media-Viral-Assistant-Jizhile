FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates cmake ninja-build g++ python3 \
    qt6-base-dev qt6-declarative-dev qt6-tools-dev qt6-tools-dev-tools libxkbcommon-dev \
    qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
COPY . /src
RUN cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel 2 \
    && ctest --test-dir build --output-on-failure \
    && QT_QPA_PLATFORM=offscreen ./build/media-hit-assistant --self-test \
    && python3 scripts/audit_qml_controls.py \
    && python3 scripts/audit_devprompt_alignment.py \
    && cmake --install build --prefix /tmp/media-hit-install \
    && test -x /tmp/media-hit-install/bin/media-hit-assistant
CMD ["/src/build/media-hit-assistant", "--self-test"]
