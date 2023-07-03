# Trash Bin for Linux

## Summary

TODO: Add a summary

## Implementation

The trash bin is implemented with shell scripts and a cron job. It contains four scripts: deleteTrash.sh, restoreTrash.sh, and cleanTrash.sh. The cron job will be used to run the cleanTrash.sh script every day at 00:00, which will clean the trash bin by deleting files that have been in the trash bin for more than 7 days. The deleteTrash.sh script is the most important script, it's core content is to repackage the `rm` command, which will use the `mv` command to instead of the `rm` command to delete files, and move the deleted files to the trash bin. The restoreTrash.sh script is used to restore the files in the trash bin.

### deleteTrash.sh

1. 判断当前用户目录是否存在.trashBin目录，如果不存在则创建.trashBin目录。
2. 支持解析命令行参数，支持以下命令行参数：
   - -h, --help: 显示帮助信息。
   - -r, -R, --recursive: remove directories and their contents recursively.
   - -d, --dir: remove empty directories.
   - -f, --force: ignore nonexistent files and arguments, never prompt.
   - -v, --verbose: explain what is being done.
   - -y: assume yes on all queries.
3. 支持 `-f` 选项，直接删除文件或目录，而不放置到回收站。
4. 增加用户交互默认需要用户确认删除，支持 `-y` 选项，不需要用户确认删除。
5. 判断文件类型并直接删除大于 2G 的文件。
6. 移动文件或目录到回收站并记录日志。
   - 获取参数的文件名或目录名
   - 生成新的文件名，在原文件（目录）加上时间后缀，便于确认删除时间
   - 生成被删除文件的历史绝对路径，用于恢复文件
   - 调用 logTrash.sh 记录原文件，新文件名，删除时间和历史绝对路径
   - 调用 mv 命令移动文件或目录到回收站

### restoreTrash.sh

支持恢复回收站中的文件或目录，支持以下命令行参数

### cleanTrash.sh

