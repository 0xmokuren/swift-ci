# swift-format をビルド済みで同梱した CI 用 image です。
# multi-stage で builder のソース展開・ビルド成果物を捨て、
# runtime stage は swift toolchain + swift-format バイナリだけにしています。

ARG SWIFT_TAG=6.0

FROM swift:${SWIFT_TAG} AS builder
ARG SF_VERSION=602.0.0
WORKDIR /src
RUN git clone --depth 1 --branch ${SF_VERSION} https://github.com/swiftlang/swift-format.git . \
    && swift build -c release \
    && install -m 0755 .build/release/swift-format /usr/local/bin/swift-format

FROM swift:${SWIFT_TAG}
COPY --from=builder /usr/local/bin/swift-format /usr/local/bin/swift-format
RUN swift-format --version
