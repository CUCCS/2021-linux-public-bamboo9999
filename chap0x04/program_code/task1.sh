#!/usr/bin/env bash

# 帮助文档
function Help {
	echo "  -d <path>			: Input file path"
	echo "  -q <percentage>		: Compress the images"
	echo "  -r <width>			: Compress the resolution of JPEG/PNG/SVG images"
	echo "  -w <text>			: Add text watermark in all images"
	echo "  -p <prefix_text>	: Type in the prefix that you want to add to the names of the pictures"
	echo "  -s <suffix_text>	: Type in the suffix that you want to add to the names of the pictures"
	echo "  -c					: Convert PNG/SVG images to JPEG images"
	echo "  -h					: Print Help"
}

# 对jpg格式图片进行图片质量压缩
function QualityCompress {
	# $1：输入的是原始图片所在的目录 $2：输入的是压缩图片的百分比

	if [ -d "later_img" ];then	#检测要保存的目录是否存在

	# 查找后缀是jpg的文件
		for img in "$1"*.jpg;
		do
			fullname="$(basename "$img")" 	# 去掉文件的目录，得到文件名和后缀
			filename="${fullname%.*}" 	# 因为删除了目录，所以得到的只有文件名
			typename="${fullname##*.}" 	# 得到文件后缀

			# 压缩图像并保存到later_img文件夹中
			convert "$img" -quality "$2" ./later_img/"$filename"."$typename" 
		done
	fi

	echo "successed JPEG quality compressing."
}

# 对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
function Resize {
	# $1：输入的是原始图片所在的目录 $2：压缩图片后的宽度

	if [ -d "later_img" ];then
	
	# 查找后缀是jpg、png、jpeg、svg的图片
	images="$(find "$1" -regex ".*\(jpg\|jpeg\|png\|svg\)")"

		for img in $images; 
		do
			fullname="$(basename "$img")"
        	filename="${fullname%.*}"
        	typename="${fullname##*.}"

			# 压缩操作
        	convert "$img" -resize "$2" ./later_img/"${filename}_resize"."$typename"
   		done
	fi
        
	echo "The resolution is obtained successfully"
}

# 对图片批量添加自定义文本水印
function Watermark {
	# $1：输入的是原始图片所在的目录 $2：文本水印

	if [ -d "later_img" ];then

	images="$(find "$1" -regex ".*\(jpg\|jpeg\|png\|svg\)")"

        for img in $images;
		do
			fullname="$(basename "$img")"
			filename="${fullname%.*}"
			typename="${fullname##*.}"
			
			# 在最上方添加白色水印
			convert "$img" -gravity north -fill white -pointsize 50 -draw "text 15,10 '$2'" ./later_img/"${filename}_watermark"."$typename"
		done
	fi
        
	echo "Watermarks are added successfully"

}

# 批量重命名——统一添加文件名前缀
function Prefix {
	# $1：输入的是原始图片所在的目录 $2：文件名前缀

	prefix=$2 #前缀

    if [ -d "later_img" ];then

		for img in "$1"*.*; # 获取目录下的全部文件
		do
			fullname="$(basename "$img")"
			filename="${fullname%.*}"
			typename="${fullname##*.}"

			new="${prefix}_${filename}" # 加上了前缀的名字

			# 添加前缀
			cp "$img" ./later_img/"$new"."$typename"
		done
	fi

	echo "Successfully renamed and added prefix"
}

# 批量重命名——统一添加文件名后缀
function Suffix {
	# $1：输入的是原始图片所在的目录 $2：文件名后缀

        suffix=$2

	if [ -d "later_img" ];then

    for img in "$1"*.*; 
		do
                fullname="$(basename "$img")"
                filename="${fullname%.*}"
                typename="${fullname##*.}"

				new="${filename}_${suffix}" # 加上了后缀的名字

				# 添加后缀
                cp "$img" ./later_img/"$new"."$typename"
        done
	fi

        echo "Successfully renamed and added suffix"
}

# 将png/svg图片统一转换为jpg格式图片
function Conversion {
	# $1：输入的是原始图片所在的目录

	if [ -d "later_img" ];then

	# 查找png和svg格式的图片
	images="$(find "$1" -regex ".*\(png\|svg\)")"

		for img in $images; 
		do
			fullname="$(basename "$img")"
			filename="${fullname%.*}"

			# 转换成jpg格式
			convert "$img" ./later_img/"$filename"".jpg"
		done
	fi

	echo "Successfully converted to jpg"
}

#main

path=""

if [[ "$#" -eq 0 ]];then
	echo -e "Please input some arguments,refer the help information below:\n"
	helpInfo
fi

while [[ "$#" -ne 0 ]]
do
	case "$1" in 
	"-d")
			if [[ "$2" != '' ]];then
				path="$2"
				shift 2 #将参数左移两位，$#也相应减少
			else
				echo "Please input a path after '-i'."
				exit 0
			fi
			;;
		"-q")
			if [[ "$2" != '' ]];then
                QualityCompress "$path" "$2"
				shift 2
			else
				echo "please input a quality argument.eg: -q 50%"
				exit 0
			fi
			;;
		"-r")
			if [[ "$2" != '' ]];then
				Resize "$path" "$2"
				shift 2
			else
				echo "Please input a pecentage for resizing.eg:-r 50"
				exit 0
			fi
			;;
		"-w")
			if [[  "$2" != ''  ]]; then
				Watermark "$path" "$2"
				shift 2
			else
				echo "Please input a watermark text. eg: -w hello"
				exit 0
			fi
			;;
		"-p")
			if [[  "$2" != ''  ]]; then
				Prefix "$path" "$2"
				shift 2
			else
				echo "Please input some words after '-p'(for prefix)"
				exit 0
			fi
			;;
		"-s")
			if [[  "$2" != ''  ]]; then
                Suffix "$path" "$2"
                shift 2
                else
                    echo "Please input some words after '-s'(for suffix)"
                    exit 0
            fi
            ;;
		"-c")
			Conversion "$path"
			shift
			;;
		"-h")
			Help
			exit 0
	esac
done