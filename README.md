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

写真は同じディレクトリに置きます。公開用の JPEG は下の圧縮スクリプトで作ります。一覧のサムネイルは `thumbnail.jpg` で、無ければ最初の画像です。画像が無いページはプレースホルダになります。

## 完成にする

`status` を `完成` にして、`finish` に日付を入れます。

```yaml
status: "完成"
finish: "2026-11-01"
```

## 写真を圧縮する

`scripts/compress-photos.py` は Hugo リポジトリの外でも動く。撮影フォルダから Obsidian の保管庫へ出すときも同じコマンドでよい。依存は Pillow だけ。

```sh
pip install pillow
python3 scripts/compress-photos.py 元のフォルダ 出力フォルダ
```

最長辺を 1600px 以下にし（小さい写真は拡大しない）、JPEG 品質 82 で書き出す。EXIF の向きはピクセルに焼き込み、EXIF / GPS / XMP / IPTC は入れない。色プロファイル（ICC）だけは残す。出力先に同じ相対パスの `.jpg` が既にあればスキップする。撮影日は画像には残さない。プラモのページならフロントマターの `start` / `finish` に書く。

HEIC は追加で `pip install pillow-heif` が要る。

## 公開画像に EXIF を残さない

`content/` と `static/` に EXIF、GPS、XMP、IPTC が残っていると CI が失敗する。メッセージどおりに次を実行して、差分をコミットする。

```sh
sudo apt install libimage-exiftool-perl exiftran python3-pil
scripts/strip-exif.sh
```

JPEG の向きは `exiftran` でロスレスに回してからメタデータを消す。検査だけなら `scripts/strip-exif.sh --check`（`exiftool` だけでよい）。

pre-commit は入れていない。使うなら自分でコピーする。

```sh
cp scripts/pre-commit.example .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
