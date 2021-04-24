#!/usr/bin/env bash

# 帮助信息
function Help {
	echo "  -r		: 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"
	echo "  -y		: 获取年龄最大和年龄最小的"
	echo "  -p		: 统计不同场上位置的球员数量、百分比"
	echo "  -n		: 获取名字最长和名字最短的球员"
	echo "  -h 		: 获取帮助信息"

}

# 统计不同年龄区间范围的球员数量和百分比
function Age {

	age_lt20=0 # 20岁以下球员数
	age_bw20to30=0 # 20到30岁球员数
	age_gt30=0 # 30岁以上球员数

	# 每行按TAB分隔，输出文本中的第6项--age
	ages=$(awk -F "\t" '{print $6}' "$1")

        for age in $ages; do
		if [[ "$age" != 'Age' ]]; then # 滤去表头Age
			if [[ "$age" -lt 20 ]];then # 20岁以下
			  age_lt20=$((age_lt20+1))
			elif [[ "$age" -ge 20 && "$age" -le 30 ]];then # 20到30岁
			  age_bw20to30=$((age_bw20to30+1))
			elif [[ "$age" -gt 30 ]];then # 大于30岁
			  age_gt30=$((age_gt30+1))
			fi
			line_num=$((line_num+1)) # 读取下一行
		fi
	done
        
	# 计算百分比，-l使用标准数学库
	age_lt20_ratio=$(printf "%.2f" "$(echo "100*${age_lt20}/$line_num" | bc -l)")
	age_bw20to30_ratio=$(printf "%.2f" "$(echo "100*${age_bw20to30}/$line_num" | bc -l)")
	age_gt30_ratio=$(printf "%.2f" "$(echo "100*${age_gt30}/$line_num" | bc -l)")

    # 使用echo打印不用格式替代符
	echo -e "年龄\t\t数量\t百分比"
	echo -e "------------------------------"
	echo -e "小于20岁：\t$age_lt20\t${age_lt20_ratio}%"
	echo -e "20到30岁：\t$age_bw20to30\t${age_bw20to30_ratio}%"
	echo -e "30岁以上：\t$age_gt30\t${age_gt30_ratio}%"
}

# 统计不同场上位置的球员数量、百分比
function Position {

	# 声明关联数组
	declare -A positions_dict 	

	# 每行按TAB分隔，输出文本中的第5项--position
	positions=$(awk -F "\t" '{ print $5 }' "$1")

	for position in $positions; do
		if [[ "$position" != 'Position' ]];then # 过滤表头
			if [[ -n "${positions_dict[$position]}" ]];then # 如果字符串非空，则加一
				positions_dict[$position]=$((positions_dict[$position]+1))
			else
				positions_dict[$position]=1
			fi
			line_num=$((line_num+1))
		fi
	done
        
	# 遍历关联数组输出结果
	echo -e "位置\t\t人数\t百分比"
	echo -e "-------------------------------"

	for position in "${!positions_dict[@]}";do
		ratio=$(printf "%.2f" "$(echo "100*${positions_dict[$position]}/$line_num" | bc -l)")
		echo -e "$position   \t ${positions_dict[$position]} \t ${ratio}%"
	done
}

# 求年龄最大和最短的成员
function AgeCompare {

	# 赋初值好进行比较
	max=0 	# 最大年龄
    min=100 	# 最小年龄

	ages=$(awk -F "\t" '{ print $6 }' "$1")

	# 找出年龄最大和最小的数值
	for age in $ages; do
		if [[ "$age" != 'Age' ]]; then 
			if [[ "$age" -lt "$min" ]]; then
				min="$age"
			fi
			if [[ "$age" -gt "$max" ]]; then
				max="$age"
			fi
			line_num=$((line_num+1))
		fi
	done
        
	# 最大年龄的球员可能有多个
	oldest_name=$(awk -F '\t' '{if($6=='"${max}"') {print $9}}' "$1");
	echo -e "年龄最大的成员：\n名字\t年龄"
	echo "------------------"
	for name in $oldest_name; do
		echo -e "$name $max"
	done

	# 最小年龄的球员也可能有多个
	youngest_name=$(awk -F '\t' '{if($6=='"$min"') {print $9}}' "$1");
	echo -e "\n年龄最小的成员：\n名字 \t 年龄"
	echo "-------------"
	for name in $youngest_name ;do
		echo -e "$name\t $min"
	done
}

# 求名字最长最短的球员
function Name {

    long=0 	# 最长名字
    short=100   # 最短名字

	#每行按TAB分隔，输出文本中的第9项--name的长度
	names=$(awk -F "\t" '{ print length($9) }' "$1")
	
	for name in $names; do
	if [[ "$name" != 'Player' ]]; then 
		if [[ "$long" -lt "$name" ]]; then
			long="$name"
		fi
		if [[ "$short" -gt "$name" ]]; then
			short="$name"
		fi
	fi
	done

	longest_name=$(awk -F '\t' '{if (length($9)=='"$long"'){print $9}}' "$1")
	echo -e "名字最长："
	echo -e "$longest_name \t $long"

	shortest_name=$(awk -F '\t' '{if (length($9)=='"$short"'){print $9}}' "$1")
	echo -e "\n名字最短："
	echo -e "$shortest_name\t$short"
}

# main函数
if [[ "$#" -eq 0 ]]; then
	echo -e "Please input some arguments, refer the Help information below:\n"
	helpInfo
fi
while [[ "$#" -ne 0 ]]; do
	case "$1" in
		"-r")
		Age "worldcupplayerinfo.tsv"; shift;;
		"-y")
		AgeCompare "worldcupplayerinfo.tsv"; shift;;
		"-p")
		Position "worldcupplayerinfo.tsv"; shift;;
		"-n")
		Name "worldcupplayerinfo.tsv"; shift;;
		"-h")
		Help; 
		exit 0
	esac
done