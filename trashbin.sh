#!/bin/bash
export PATH="$HOME/.config/linux-Trashbin":$PATH
# echo $PATH
chmod +x $HOME/.config/linux-Trashbin/*.sh

alias del="deleteTrash.sh"
alias res="restoreTrash.sh"
alias clt="cleanTrash.sh"

# 检查定时任务是否存在
if [[ -z `crontab -l | grep "cleanTrash.sh"` ]]; then
    # 添加定时任务
    crontab -l > /tmp/crontab.bak
    echo "0 0 * * 0 $HOME/.config/linux-Trashbin/cleanTrash.sh" >> /tmp/crontab.bak
    crontab /tmp/crontab.bak
    rm -rf /tmp/crontab.bak
fi
