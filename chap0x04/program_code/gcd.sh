#!/usr/bin/env bash

#求两个数的最大公约数gcd

#从键盘中输入a和b
read -p "请输入a和b: " a b # -p表示会用一段文本来提示用户输入

tmp=$a

if [[ $tmp -gt $b ]];then # a>b
    tmp=$b # 因为最大公约数不会超过a、b之间小的那个
fi

while [[ $tmp -ne 0 ]];do
    x=$((a%tmp))
    y=$((b%tmp))

    if [[ $x -eq 0 && $y -eq 0 ]];then
        echo "a和b的最大公约数为：$tmp"
        break
    fi
    tmp=$((tmp - 1)) # tmp逐渐递减，知道a和b都能整除
done