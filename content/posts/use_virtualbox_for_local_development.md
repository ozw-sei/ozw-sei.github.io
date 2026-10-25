---
title: ローカル開発環境にVirtualBoxを使用する 
date: 2020-02-22T22:37:05+09:00
draft: false
tags: ["virtualbox", "debian"]
categories: ["til"]
---

## 経緯
DockerDesktop(Windows)、WSLとの戦いに敗れた.
プロジェクト単位での仮想環境というより適当に使えるローカル開発環境が欲しかった。


## やったこと
1. VirtualBoxのインストール
2. Debian10(Buster)のイメージのＤＬ
3. HostOnlyNetworkの設定

## 1の手順
https://www.virtualbox.org/wiki/Downloads

## 2の手順
https://www.debian.org/distrib/

## 3の手順
ホストＯＳ側でホストオンリーネットワークを設定.

ゲストＯＳで下記の設定を追加

```ini
"/etc/systemd/network/enp0s8.network" というファイルを作り，次のように記入する．
[Match]
enp0s8

[Network]
Address=192.168.151.100
DNS=192.168.151.1
```

sudo service networkservice restart

以上.


以下の記事を参考にしました(Thank you!!)。
https://qiita.com/Yoshiki-Takahashi/items/7274dff15dbafee5b118

