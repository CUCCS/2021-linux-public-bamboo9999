#!/usr/bin/env bash

LANG=en_US.UTF-8

# 帮助文档
function Help {

	echo "  -a <num>		: 统计访问来源主机TOP 100和分别对应出现的总次数"
	echo "  -b <num>		: 统计访问来源主机TOP 100 IP和分别对应出现的总次数"
	echo "  -c <num>		: 统计最频繁被访问的URL TOP 100"
	echo "  -d       		: 统计不同响应状态码的出现次数和对应百分比"
	echo "  -e <num>		: 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
	echo "  -f <num><URL>	: 给定URL输出TOP 100访问来源主机"
	echo "  -h          	: 获取帮助文档"
}

# 统计访问来源主机TOP 100和分别对应出现的总次数
function HostTop {
	# $1：file  $2：num

	# sed：读取文件内容到模式空间并删除第一行表头
	# awk以TAB为分隔符，得到sed输文本出的第一项host
	# sort默认是从小到大，uniq -c表示显示该主机重复出现的次数
	# sort -n 按数值大小排序，-r表示逆序
	# head -n指定显示行数，即显示100行
	host=$(sed '1d' "$1" | awk -F '\t' '{print $1}' | sort | uniq -c | sort -nr | head -n $2)
	
	echo -e "Top $2 Host:\n$host\n"  >> HostTop.txt
}

# 统计访问来源主机TOP 100 IP和分别对应出现的总次数
function IpTop {
	# $1：file  $2：num

	# awk识别ip并统计出现次数
	# ~ 匹配正则表达式 END语句块在读完所有行后执行
	IP=$(sed '1d' "$1" |awk -F'\t' '{print $1}' | grep -E "^[0-9]" | sort | uniq -c | sort -nr| head -n 100)
	echo -e "Top $2 IP:\n$IP\n" >> IpTop.txt
}

# 统计最频繁被访问的URL TOP 100
function URLTop {
	# $1：file  $2：num

	URL=$(sed '1d' "$1" | awk -F '\t' '{print $5}' | sort | uniq -c | sort -nr | head -n $2)
	echo -e "Top$2 URL:\n$URL\n" >> URLTop.txt
}

# 统计不同响应状态码的出现次数和对应百分比
function Response {
	# $1：file

	code=$(sed '1d' "$1" | awk '{a[$6]++;s+=1}END{for (i in a) printf "%s %d %6.4f%%\n", i, a[i], a[i]/s*100}' | sort)
	echo -e " Responses appearing times and ratio:\n$code\n" >> Response.txt

}

# 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
function Response4 {
	# $1：file  $2：num

	# 先找出4XX的状态码
	# sort -u用来去除重复行
	code=$(sed '1d' "$1" | awk -F '\t' '{if($6~/^4/) {print $6}}' | sort -u )
	
	#对每一个4XX状态码重新遍历文件
	for n in $code ; do
		top=$(awk -F '\t' '{ if($6=='"$n"') {a[$5]++}} END {for(i in a) {print a[i],i}}' "$1" | sort -nr | head -n $2)
		echo -e "${n} Top $2 URL:\n$top\n" >> ResponseTop.txt
	done
}

#给定URL输出TOP 100访问来源主机
function URLHost {
	# $1：file  $2：URL  $3：num

	uh=$(sed '1d' "$1" | awk -F '\t' '{if($5=="'$2'") {host[$1]++}} END{for (i in host) {print host[i],i}}' | sort -nr | head -n $3)
	echo -e "URL: $2\n\n${uh}" >> URLHost.txt

}

# main 

if [[ "$#" -eq 0 ]]; then
	echo -e "Please input some arguments, refer the help information below:\n"
	helpInfo
fi

while [[ "$#" -ne 0 ]]; do
	case "$1" in    
		# $1：file  $2：num
		"-a")HostTop "web_log.tsv" "$2"; shift 2;;
		"-b")IpTop "web_log.tsv" "$2"; shift 2;;
		"-c")URLTop "web_log.tsv" "$2"; shift 2;; 
		"-d")Response "web_log.tsv"; shift;;
		"-e")Response4 "web_log.tsv" "$2"; shift 2;;
		"-f")
		# $1：file  $2：URL  $3：num
			if [[ -n "$2" ]]; then
				URLHost "web_log.tsv" "$2" "$3"
				shift 3
			else
				echo "Please input an URL after '-f'."
				exit 0
			fi
			;;
		"-h")Help;
        exit 0
        esac
done