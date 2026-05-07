#!/bin/bash
# Docker/LXC 内核配置脚本
# 用于向 defconfig 追加 Docker 官方要求的全部内核选项
# 用法: ./add-lxc-docker-kernel-config.sh <defconfig路径>

set -e

DEFCONFIG="$1"

if [ -z "$DEFCONFIG" ] || [ ! -f "$DEFCONFIG" ]; then
    echo "用法: $0 <defconfig路径>"
    echo "示例: $0 android-kernel/arch/arm64/configs/sagit_defconfig"
    exit 1
fi

echo "=== Docker/LXC 内核配置 ==="
echo "目标: $DEFCONFIG"

# 向defconfig添加配置项（跳过已存在的）
add_config() {
    local config="$1"
    local key="${config%%=*}"

    # 去掉 "# " 前缀用于检查（处理 "is not set" 类型）
    local check_key="${key#\# }"

    if ! grep -q "^${check_key}=" "$DEFCONFIG" 2>/dev/null && \
       ! grep -q "^# ${check_key} is not set" "$DEFCONFIG" 2>/dev/null; then
        echo "$config" >> "$DEFCONFIG"
        echo "  + $config"
    else
        # 如果已有配置，用新值覆盖
        sed -i "s|^${check_key}=.*|${config}|" "$DEFCONFIG" 2>/dev/null || true
        sed -i "s|^# ${check_key} is not set|${config}|" "$DEFCONFIG" 2>/dev/null || true
        echo "  = $config (已更新)"
    fi
}

echo ""
echo "--- 命名空间 ---"
add_config "CONFIG_NAMESPACES=y"
add_config "CONFIG_UTS_NS=y"
add_config "CONFIG_IPC_NS=y"
add_config "CONFIG_USER_NS=y"
add_config "CONFIG_PID_NS=y"
add_config "CONFIG_NET_NS=y"
add_config "CONFIG_DEVPTS_MULTIPLE_INSTANCES=y"

echo ""
echo "--- cgroup v1 子系统 ---"
add_config "CONFIG_CGROUP_PIDS=y"
add_config "CONFIG_MEMCG=y"
add_config "CONFIG_MEMCG_SWAP=y"
add_config "CONFIG_MEMCG_SWAP_ENABLED=y"
add_config "CONFIG_MEMCG_KMEM=y"
add_config "CONFIG_CPUSETS=y"
add_config "CONFIG_CGROUP_PERF=y"
add_config "CONFIG_CGROUP_HUGETLB=y"
add_config "CONFIG_CGROUP_FREEZER=y"
add_config "CONFIG_CGROUP_DEVICE=y"
add_config "CONFIG_CFS_BANDWIDTH=y"
add_config "CONFIG_FAIR_GROUP_SCHED=y"
add_config "CONFIG_RT_GROUP_SCHED=y"

echo ""
echo "--- 块设备/cgroup IO ---"
add_config "CONFIG_BLK_CGROUP=y"
add_config "CONFIG_BLK_DEV_THROTTLING=y"
add_config "CONFIG_IOSCHED_CFQ=y"
add_config "CONFIG_CFQ_GROUP_IOSCHED=y"
add_config "CONFIG_BTRFS_FS=y"
add_config "CONFIG_BTRFS_FS_POSIX_ACL=y"
add_config "CONFIG_BLK_DEV_DM=y"
add_config "CONFIG_DM_THIN_PROVISIONING=y"

echo ""
echo "--- 网络核心 ---"
add_config "CONFIG_NETFILTER=y"
add_config "CONFIG_NETFILTER_ADVANCED=y"
add_config "CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y"
add_config "CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y"
add_config "CONFIG_NETFILTER_XT_MATCH_IPVS=y"
add_config "CONFIG_NETFILTER_XT_MARK=y"
add_config "CONFIG_VETH=y"
add_config "CONFIG_BRIDGE=y"
add_config "CONFIG_BRIDGE_NETFILTER=y"
add_config "CONFIG_BRIDGE_VLAN_FILTERING=y"
add_config "CONFIG_VXLAN=y"
add_config "CONFIG_IPVLAN=y"
add_config "CONFIG_MACVLAN=y"
add_config "CONFIG_DUMMY=y"
add_config "CONFIG_POSIX_MQUEUE=y"

echo ""
echo "--- iptables/NAT ---"
add_config "CONFIG_IP_NF_IPTABLES=y"
add_config "CONFIG_IP_NF_FILTER=y"
add_config "CONFIG_IP_NF_NAT=y"
add_config "CONFIG_IP_NF_TARGET_MASQUERADE=y"
add_config "CONFIG_IP_NF_TARGET_REDIRECT=y"
add_config "CONFIG_NF_NAT=y"
add_config "CONFIG_NF_NAT_IPV4=y"
add_config "CONFIG_NF_NAT_NEEDED=y"
add_config "CONFIG_NF_NAT_FTP=y"
add_config "CONFIG_NF_NAT_TFTP=y"
add_config "CONFIG_NF_CONNTRACK=y"
add_config "CONFIG_NF_CONNTRACK_IPV4=y"
add_config "CONFIG_NF_CONNTRACK_FTP=y"
add_config "CONFIG_NF_CONNTRACK_TFTP=y"
add_config "CONFIG_NET_CLS_CGROUP=y"
add_config "CONFIG_CGROUP_NET_PRIO=y"

echo ""
echo "--- IPVS ---"
add_config "CONFIG_IP_VS=y"
add_config "CONFIG_IP_VS_NFCT=y"
add_config "CONFIG_IP_VS_PROTO_TCP=y"
add_config "CONFIG_IP_VS_PROTO_UDP=y"
add_config "CONFIG_IP_VS_RR=y"

echo ""
echo "--- 安全/审计/SELinux/AppArmor ---"
add_config "CONFIG_AUDIT=y"
add_config "CONFIG_AUDITSYSCALL=y"
add_config "CONFIG_SECURITY_SELINUX=y"
add_config "CONFIG_SECURITY_APPARMOR=y"
add_config "CONFIG_SECCOMP=y"
add_config "CONFIG_SECCOMP_FILTER=y"

echo ""
echo "--- 文件系统 ---"
add_config "CONFIG_EXT4_FS=y"
add_config "CONFIG_EXT4_FS_POSIX_ACL=y"
add_config "CONFIG_EXT4_FS_SECURITY=y"
add_config "CONFIG_FS_POSIX_ACL=y"
add_config "CONFIG_TMPFS_XATTR=y"
add_config "CONFIG_TMPFS_POSIX_ACL=y"
add_config "CONFIG_SQUASHFS=y"
add_config "CONFIG_OVERLAY_FS=y"

echo ""
echo "--- 加密/XFRM ---"
add_config "CONFIG_CRYPTO=y"
add_config "CONFIG_CRYPTO_AEAD=y"
add_config "CONFIG_CRYPTO_GCM=y"
add_config "CONFIG_CRYPTO_SEQIV=y"
add_config "CONFIG_CRYPTO_GHASH=y"
add_config "CONFIG_XFRM=y"
add_config "CONFIG_XFRM_USER=y"
add_config "CONFIG_XFRM_ALGO=y"
add_config "CONFIG_INET_ESP=y"
add_config "CONFIG_INET_XFRM_MODE_TRANSPORT=y"

echo ""
echo "--- BPF ---"
add_config "CONFIG_BPF=y"
add_config "CONFIG_BPF_SYSCALL=y"
add_config "CONFIG_BPF_JIT=y"
add_config "CONFIG_CGROUP_BPF=y"

echo ""
echo "--- 关闭Android网络限制 ---"
add_config "# CONFIG_ANDROID_PARANOID_NETWORK is not set"

echo ""
echo "=== Docker/LXC 内核配置完成 ==="
