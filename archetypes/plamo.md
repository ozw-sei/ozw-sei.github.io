---
title: "{{ replace .Name "-" " " }}"
date: {{ .Date }}
draft: true
kit: "{{ replace .Name "-" " " }}"
maker: ""
scale: ""
status: "制作中"
start: "{{ slicestr .Date 0 10 }}"
finish: ""
---

制作メモを書く。
