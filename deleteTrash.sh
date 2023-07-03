#!/bin/bash

# This script is used to delete files and move them to the trash bin.

# Get the current time.
time=$(date "+%Y-%m-%d-%H:%M:%S")
# Get the current user.
user=$(whoami)
# Get the current directory.
dir=$(pwd)

# Get the trash bin directory.
trashBinDir="/home/$user/.trashBin"
# Get the log file.
logFile="${trashBinDir}/.log"

function usage() {
      echo "Usage: deleteTrash.sh [OPTION]... [FILE]..."
      echo "Delete files and move them to the trash bin."
      echo ""
      echo "  -h, --help              display this help and exit"
      echo "  -r, -R, --recursive     remove directories and their contents recursively"
      echo "  -d, --dir               remove empty directories"
      echo "  -f, --force             ignore nonexistent files and arguments, never prompt"
      echo "  -v, --verbose           explain what is being done"
      echo "  -y                      assume yes on all queries"
      echo ""
      echo "By default, only prompt at the beginning of the removal process."
}

# 判断当前用户是否存在 .trashBin 目录，如果不存在则创建 .trashBin 目录。
if [ ! -d "${trashBinDir}" ]; then
    mkdir "${trashBinDir}"
fi

# 判断是否有参数传入。
if [ $# -eq 0 ]; then
    echo "No arguments passed."
    usage
    exit 1
fi

prompt=true

# 解析参数
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -r|-R|--recursive)
            recursive=true
            ;;
        -d|--dir)
            emptyDir=true
            ;;
        -f|--force)
            force=true
            ;;
        -v|--verbose)
            verbose=true
            ;;
        -y)
            yes=true
            ;;
        *)
            targetArry+=( "$1" )
            ;;
    esac
    shift
done

# 循环处理target数组中的文件
for target in "${targetArry[@]}"; do
    # 判断当前变量是相对路径，绝对路径或者是文件名
    if [[ $target == /* ]]; then
        # 绝对路径 则 截取路径和文件名
        path=${target%/*}
        filename=${target##*/}
    elif [[ $target == */* ]]; then
        # 相对路径
        path=`pwd`/${target%/*}
        filename=${target##*/}
    else
        # 文件名
        path=`pwd`
        filename=$target
    fi
    mapfile -t files < <(find "$path" -maxdepth 1 -name "$filename")
    # 如果files数组为空则提示文件不存在
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "del: cannot delete '$target': No such file or directory"
        continue
    fi
    
    for file in "${files[@]}"; do
        absPath=$(readlink -f "$file")
        absPath=${absPath%/*}
        name=${file##*/}
        # echo "absPath: $absPath; name: $name"
        if [[ -f $file ]]; then
            # 文件
            # 检查文件是否 大于 2GB
            fileSize=$(du -b "$file" | awk '{print $1}')
            if [[ $fileSize -gt 2147483648 ]]; then
                # 大于 2GB 则提示是否直接删除
                if [[ $force == true ]]; then
                    # 强制删除
                    rm -rf "$file"
                elif [[ $yes == true ]]; then
                    # 自动删除
                    rm -rf "$file"
                elif [[ $prompt == true ]]; then
                    # 提示删除
                    echo "$file is larger than 2GB, are you sure you want to remove it? [y/n]"
                    read -r answer
                    if [[ $answer == "y" || $answer == "Y" ]]; then
                        rm -rf "$file"
                    else
                        continue
                    fi
                else
                    # 默认删除
                    rm -rf "$file"
                fi
                # 如果verbose为true则显示删除信息
                if [[ $verbose == true ]]; then
                    echo "[$time] $user remove $file"
                fi
            else
                # 小于 2GB 则提示是否移动到回收站
                if [[ $force == true ]]; then
                    # 强制删除
                    # echo "${trashBinDir}/${name}.${time}"
                    mv "$file" "${trashBinDir}/${name}.${time}"
                elif [[ $yes == true ]]; then
                    # 自动删除
                    mv "$file" "${trashBinDir}/${name}.${time}"
                elif [[ $prompt == true ]]; then
                    # 提示删除
                    echo "del: delete regular file '$file'? [y/n]"
                    read -r answer
                    if [[ $answer == "y" || $answer == "Y" ]]; then
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    else
                        continue
                    fi
                else
                    # 默认删除
                    mv "$file" "${trashBinDir}/${name}.${time}"
                fi
                # 如果verbose为true则显示删除信息
                if [[ $verbose == true ]]; then
                    echo "[$time] $user delete $file"
                fi
                # 记录日志
                echo "[$time] $user ${name}.${time} $file" >> "$logFile"
            fi
        elif [[ -d $file ]]; then
            # 若 emptyDir 为 true 则校验目录是否为空
            if [[ $emptyDir == true ]]; then
                # 判断目录是否为空
                if [[ -z $(ls -A "$file") ]]; then
                    # 空目录
                    # 判断是否强制删除
                    if [[ $force == true ]]; then
                        # 强制删除
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    elif [[ $yes == true ]]; then
                        # 自动删除
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    elif [[ $prompt == true ]]; then
                        # 提示删除
                        echo "del: remove directory '$file'? [y/n]"
                        read -r answer
                        if [[ $answer == "y" || $answer == "Y" ]]; then
                            mv "$file" "${trashBinDir}/${name}.${time}"
                        else
                            continue
                        fi
                    else
                        # 默认删除
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    fi
                    # 如果verbose为true则显示删除信息
                    if [[ $verbose == true ]]; then
                        echo "[$time] $user remove $file"
                    fi
                    # 记录日志
                    echo "[$time] $user ${name}.${time} $file" >> "$logFile"
                else
                    # 非空目录则提示无法删除，目录非空
                    echo "del: cannot delete '$file': Directory not empty"
                fi
            elif [[ $recursive == true ]]; then
                # 判断目录大小是否大于 2GB
                dirSize=$(du --max-depth 0 -b "${file}" | awk '{print $1}')
                if [[ ${dirSize} -gt 2147483648 ]]; then
                    # 大于 2GB 则提示是否直接删除
                    if [[ $force == true ]]; then
                        # 强制删除
                        rm -rf "$file"
                    elif [[ $yes == true ]]; then
                        # 自动删除
                        rm -rf "$file"
                    elif [[ $prompt == true ]]; then
                        # 提示删除
                        echo "$file is larger than 2GB, are you sure you want to remove it? [y/n]"
                        read -r answer
                        if [[ $answer == "y" || $answer == "Y" ]]; then
                            rm -rf "$file"
                        else
                            continue
                        fi
                    else
                        # 默认删除
                        rm -rf "$file"
                    fi
                    # 如果verbose为true则显示删除信息
                    if [[ $verbose == true ]]; then
                        echo "[$time] $user remove $file"
                    fi
                else
                    # 小于 2GB 则提示是否移动到回收站
                    if [[ $force == true ]]; then
                        # 强制删除
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    elif [[ $yes == true ]]; then
                        # 自动删除
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    elif [[ $prompt == true ]]; then
                        # 提示删除
                        echo "del: delete directory '$file'? [y/n]"
                        read -r answer
                        if [[ $answer == "y" || $answer == "Y" ]]; then
                            mv "$file" "${trashBinDir}/${name}.${time}"
                        else
                            continue
                        fi
                    else
                        # 默认删除
                        mv "$file" "${trashBinDir}/${name}.${time}"
                    fi
                    # 如果verbose为true则显示删除信息
                    if [[ $verbose == true ]]; then
                        echo "[$time] $user delete $file"
                    fi
                    # 记录日志
                    echo "[$time] $user ${name}.${time} $file" >> "$logFile"
                fi

            else
                echo "del: cannot delete '$file': Is a directory"
            fi
        
        else
            # 不存在
            echo "No such file or directory: $file"
            continue
        fi
    done
done

