---
title: yasnippetのTemplateの中でElispの結果を使用したい
date: 2020-02-23T19:07:31+09:00
draft: false
tags: [ "emacs", "yasnippet" ]
categories: [ "til" ]
---

Hugoのヘッダー情報の日付にiso8601でDateTimeを追加するものを書いてみた。

yasnippetのスニッペット展開時に日付を一緒に挿入してほしかったのだけど、snippet中でelispの評価ができるのかがわからなかったのだけど、
` で囲むとできるらしい。

便利


```yaml
---
title: ${1:title}
date: `(concat
 (format-time-string "%Y-%m-%dT%T")
 ((lambda (x) (concat (substring x 0 3) ":" (substring x 3 5)))
  (format-time-string "%z")))`
draft: true
---

$0

```



参考
- [Embedded Emacs-lisp code](https://joaotavora.github.io/yasnippet/snippet-development.html#orgcde188c)