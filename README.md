# 日々のChangeLog

Hugo extended 0.168.0 でビルドします。テーマ `contrast-hugo` は git submodule です。

```sh
git submodule update --init
hugo --minify
```

`source` への push で GitHub Actions がビルドし、`master` に公開します。

## プラモを追加する

ページバンドルなので、写真を Markdown の隣に置けます。ディレクトリ名が URL になります。

```sh
hugo new content plamo/kit-name/index.md
```

`content/plamo/kit-name/index.md` を埋めます。

- `status` は `制作中` か `完成`
- `kit`（キット名）、`maker`（メーカー）、`scale`（スケール）
- `start` と `finish` は `2026-10-25` の形。まだ終わっていなければ `finish` は空

`draft: true` の間は出ません。公開するときは `draft: false` にします。

写真は同じディレクトリに置きます。一覧のサムネイルは `thumbnail.jpg` で、無ければ最初の画像です。画像が無いページはプレースホルダになります。

## 完成にする

`status` を `完成` にして、`finish` に日付を入れます。

```yaml
status: "完成"
finish: "2026-11-01"
```
