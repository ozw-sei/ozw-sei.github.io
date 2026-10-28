# 日々のChangeLog

最初に `pre-commit install`（または `make setup`）を一度実行する。写真に EXIF / GPS が残っているとコミットできない。公開する JPEG は、その前に `scripts/compress-photos.py` を通す。

Hugo extended 0.168.0 でビルドします。テーマ [Stack](https://github.com/CaiJimmy/hugo-theme-stack) は `themes/hugo-theme-stack` の git submodule です。SCSS は Dart Sass（`sass` コマンド）でコンパイルします。

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

写真は同じディレクトリに置きます。公開用の JPEG は下の圧縮スクリプトで作ります。

カードのカバーはフロントマターの `image` です。指定が無いページは、一覧にカバーを出しません。

```yaml
image: "cover.jpg"
```

複数枚をギャラリーにするときは、同じ行に画像を並べ、あいだを半角スペース2つにします。

```markdown
![背中](back.jpg)  ![腹](belly.jpg)
```

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

コミット時の検査が本線です。`pip install pre-commit` のあと、次のどちらかを一度実行します。

```sh
pre-commit install
make setup
```

フックは [exif-stripper](https://github.com/stefmolin/exif-stripper) 1.3.1（`strip-exif`）です。ステージした画像に EXIF があるとコミットを止め、GPS、メーカー、シリアル、XMP、IPTC を消したファイルに書き換えます。直したファイルを足し直してから、もう一度コミットします。

このフックは `Orientation` を残し、ピクセル自体は回転しません。ブラウザは向きタグを見て正しく表示しますが、タグを無視する処理ではスマホ写真が横倒しになります。フックが書き換えた JPEG にも向きタグが残るので、CI の検査にも引っかかります。公開前に `scripts/compress-photos.py` を通せば、向きはピクセルに入り、メタデータは残りません。

CI は保険です。`content/` と `static/` に EXIF、GPS、XMP、IPTC が残っていると失敗します。そのときは次を実行して差分をコミットします。

```sh
sudo apt install libimage-exiftool-perl exiftran python3-pil
scripts/strip-exif.sh
```

JPEG の向きは `exiftran` でロスレスに回してからメタデータを消します。検査だけなら `scripts/strip-exif.sh --check` です。