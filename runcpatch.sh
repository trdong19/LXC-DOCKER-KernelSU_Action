#!/bin/bash
# runc cgroup 补丁
# 修复 Docker/runc 在 cgroup v1 下的文件前缀问题
# 用法: ./runcpatch.sh <cgroup.c路径>

set -e

RUNC_ADD_FILE="$1"

if [ -z "$RUNC_ADD_FILE" ] || [ ! -f "$RUNC_ADD_FILE" ]; then
    echo "用法: $0 <cgroup.c路径>"
    echo "示例: $0 android-kernel/kernel/cgroup/cgroup.c"
    exit 1
fi

echo "=== runc cgroup 补丁 ==="
echo "目标: $RUNC_ADD_FILE"

# 检查是否已打过补丁
if grep -q "kernfs_create_link(cgrp->kn, name, kn)" "$RUNC_ADD_FILE"; then
    echo "补丁已存在，跳过"
    exit 0
fi

# 检查目标函数是否存在
if ! grep -q "^static int cgroup_add_file" "$RUNC_ADD_FILE"; then
    echo "警告: 未找到 cgroup_add_file 函数，跳过补丁"
    exit 0
fi

# 创建临时文件
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# 定位 cgroup_add_file 函数中的 return 0 位置并注入补丁
row=$(sed -n -e '/^static int cgroup_add_file/=' "$RUNC_ADD_FILE")

# 提取从函数开始到第一个 return 0 的内容来定位注入点
sed -n -e '/static int cgroup_add_file/,/return 0/p' "$RUNC_ADD_FILE" > "$TMPFILE"
row2=$(sed -n -e '/return 0/=' "$TMPFILE")
row3=$((row + row2 - 1))

# 注入补丁代码
sed -i "$row3 i\\        }" "$RUNC_ADD_FILE"
sed -i "$row3 i\\                kernfs_create_link(cgrp->kn, name, kn);" "$RUNC_ADD_FILE"
sed -i "$row3 i\\                snprintf(name, CGROUP_FILE_NAME_MAX, \"%s.%s\", cft->ss->name, cft->name);" "$RUNC_ADD_FILE"
sed -i "$row3 i\\        if (cft->ss && (cgrp->root->flags & CGRP_ROOT_NOPREFIX) && !(cft->flags & CFTYPE_NO_PREFIX)) {" "$RUNC_ADD_FILE"

# 验证补丁
if grep -q "kernfs_create_link(cgrp->kn, name, kn)" "$RUNC_ADD_FILE"; then
    echo "补丁应用成功"
else
    echo "错误: 补丁验证失败"
    exit 1
fi
