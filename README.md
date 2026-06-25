# swift-ci

複数 Swift プロジェクトで共有する CI 部品をまとめたリポジトリです。

現状の提供物:

- `Dockerfile` — `swift:<tag>` をベースに [`swiftlang/swift-format`](https://github.com/swiftlang/swift-format) をビルド済みで同梱した container image
- `.github/workflows/build-image.yml` — image を `ghcr.io/<owner>/swift-ci` に push する workflow
- `.github/workflows/swift-format-lint.yml` — 他リポから `workflow_call` で呼べる reusable workflow

## image のタグ

| tag | 中身 |
| --- | --- |
| `latest` | 直近 build と同じ |
| `swift<SWIFT_TAG>-sf<SF_VERSION>` | 例: `swift6.0-sf602.0.0` |

バージョン更新は `workflow_dispatch` の input で `swift_tag` / `sf_version` を指定して `build-image.yml` を実行してください。

## 利用側 (他リポ) の書き方

```yaml
# .github/workflows/lint.yml
on:
  pull_request:
    paths:
      - '**/*.swift'
      - '.swift-format'

jobs:
  swift-format:
    uses: 0xmokuren/swift-ci/.github/workflows/swift-format-lint.yml@v1
    with:
      paths: "Sources/ Tests/"
```

reusable workflow の default image は `ghcr.io/0xmokuren/swift-ci:swift6.0-sf602.0.0` で固定済みです。バージョン違いを使いたい時のみ `image:` を override してください。さらに厳密にしたい場合は image digest (`ghcr.io/0xmokuren/swift-ci@sha256:...`) や reusable workflow を commit SHA で参照する形も使えます。

## 初期セットアップ手順

1. このリポジトリを GitHub に作成し、ファイル一式を push する
2. `Settings → Actions → General → Workflow permissions` で **Read and write** を有効化 (もしくは `packages: write` が `permissions:` で宣言済みのため不要)
3. `build-image.yml` を一度 `workflow_dispatch` で実行し、`ghcr.io/<owner>/swift-ci:latest` を生成する
4. `Packages → swift-ci → Package settings` で visibility を **Public** にする (他リポから無認証で pull させる場合)
5. 利用側リポの workflow を `uses: 0xmokuren/swift-ci/.github/workflows/swift-format-lint.yml@main` に差し替える
