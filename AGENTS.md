# エージェント向け

コミットする前に、このクローンでまだならフックを有効にする。

```sh
pre-commit install
```

`make setup` でも同じ。

写真をこのリポジトリに入れるときは、必ず先に `scripts/compress-photos.py` を通す。最長辺 1600px、JPEG 品質 82 で、EXIF の向きをピクセルに焼き込み、GPS などのメタデータを落とす。

```sh
python3 scripts/compress-photos.py 元のフォルダ 出力フォルダ
```

`pre-commit` の [exif-stripper](https://github.com/stefmolin/exif-stripper) 1.3.1（hook id `strip-exif`）は、メタデータ付き画像のコミットを止めて GPS やシリアルを消す。向きタグは残し、ピクセルは回転しない。スマホ写真をそのまま通すと横倒しに見える処理がある。圧縮スクリプトを先に使う。

CI の EXIF 検査は保険で、`content/` と `static/` に EXIF が残っていると失敗する。
