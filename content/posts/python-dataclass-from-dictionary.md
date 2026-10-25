---
title: Pythonのデータクラスをdictionaryからデシリアライズする書き方
date: 2020-02-23T22:06:17+09:00
draft: false
tags: ["python"]
categories: ["til"]
---

Pythonのデータクラスをdictionaryからデシリアライズする書き方
同僚のコードレビューをしていたえときにレスポンスのdictをそのまま使っていたのだけど、
「短いコードだから辞書のままで良くない？class書くのボイラープレート多いし」と心の声が聞こえたので覚書。

Python3.7以降ならば動作するはず。

キーが足りないと動かないので注意

```python
from dataclasses import dataclass

@dataclass
class Person:
    name: str
    home_town: str
    age: int

source_dict = {
    "name": "Mother Fxxer",
    "home_town": "Kick Ass",
    "age": 16
}

# 普通に作る
normal = Person("Mother Fxxer", "Kick Ass", 16)

# 辞書から作る
from_dict = Person(**source_dict)

print(normal == from_dict) 

## おまけ
# キーが足りない場合
source_dict = {
}

from_dict = Person(**source_dict)
# Traceback (most recent call last):
#  File "qr_Z3i1cj", line 27, in <module>
#    from_dict = Person(**source_dict)
# TypeError: __init__() missing 3 required positional arguments: 'name', 'home_town', and 'age'


```




