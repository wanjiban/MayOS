#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好
# 修改IP项的EOF于EOF之间请不要插入其他扩展代码，可以删除或注释里面原本的代码



cat >$NETIP <<-EOF
uci set network.lan.ipaddr='10.0.0.1'                      # IPv4 地址(openwrt后台地址)
uci set network.lan.netmask='255.255.255.0'                   # IPv4 子网掩码
#uci set network.lan.gateway='192.168.2.1'                    # 旁路由设置 IPv4 网关（去掉uci前面的#生效）
#uci set network.lan.broadcast='192.168.2.255'                # 旁路由设置 IPv4 广播（去掉uci前面的#生效）
#uci set network.lan.dns='223.5.5.5 114.114.114.114'          # 旁路由设置 DNS(多个DNS要用空格分开)（去掉uci前面的#生效）
uci set network.lan.delegate='0'                              # 去掉LAN口使用内置的 IPv6 管理(若用IPV6请把'0'改'1')
uci set dhcp.@dnsmasq[0].filter_aaaa='1'                      # 禁止解析 IPv6 DNS记录(若用IPV6请把'1'改'0')

#uci set dhcp.lan.ignore='1'                                  # 旁路由关闭DHCP功能（去掉uci前面的#生效）
#uci delete network.lan.type                                  # 旁路由去掉桥接模式（去掉uci前面的#生效）
uci set system.@system[0].hostname='MayOS'                    # 修改主机名称为OpenWrt-123
#uci set ttyd.@ttyd[0].command='/bin/login -f root'           # 设置ttyd免帐号登录（去掉uci前面的#生效）

# 如果有用IPV6的话,可以使用以下命令创建IPV6客户端(LAN口)（去掉全部代码uci前面#号生效）
#uci set network.ipv6=interface
#uci set network.ipv6.proto='dhcpv6'
#uci set network.ipv6.ifname='@lan'
#uci set network.ipv6.reqaddress='try'
#uci set network.ipv6.reqprefix='auto'
#uci set firewall.@zone[0].network='lan ipv6'

# LAN WAN
uci set network.lan.ifname='eth1 eth2 eth3'
uci set network.wan.ifname='eth0'
uci set network.wan6.ifname='eth0'
uci delete network.wan6
uci delete network.lan.ip6assign
uci delete network.globals.ula_prefix

#DHCP
uci delete dhcp.lan.ra
uci delete dhcp.lan.dhcpv6
uci commit dhcp
EOF


# 把bootstrap替换成argon为源码必选主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],源码内必须有该主题,要不然编译失败）
sed -i "s/bootstrap/argon/ig" feeds/luci/collections/luci/Makefile


# 编译多主题时,设置固件默认主题（可自行修改您要的,主题名称必须对,比如下面代码的[argon],和肯定编译了该主题,要不然进不了后台）
#sed -i "/exit 0/i\uci set luci.main.mediaurlbase='/luci-static/argon' && uci commit luci" "${FIN_PATH}"


# 增加个性名字 ${Author} 默认为你的github帐号,修改时候把 ${Author} 替换成你要的
sed -i "s/OpenWrt /MayOS Build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" "${ZZZ_PATH}"

# 设置首次登录后台密码为空（进入openwrt后自行修改密码）
sed -i '/CYXluq4wUazHjmCDBCqXF/d' "${ZZZ_PATH}"

# 修改默认内核（所有机型都适用，只要您编译的机型源码附带了其他内核，请至编译说明的第12条查看）
#sed -i 's/PATCHVER:=5.10/PATCHVER:=5.4/g' target/linux/x86/Makefile


# 取消路由器每天跑分任务
sed -i "/exit 0/i\sed -i '/coremark/d' /etc/crontabs/root" "${FIN_PATH}"


# 更改使用OpenClash的分支代码，把下面的master改成dev就使用dev分支，改master就是用master分支，改错的话就默认使用master分支
export OpenClash_branch='master'


# K3专用，编译K3的时候只会出K3固件（其他机型也适宜,把phicomm_k3和对应路径替换一下，名字要绝对正确才行）
#sed -i 's|^TARGET_|# TARGET_|g; s|# TARGET_DEVICES += phicomm_k3|TARGET_DEVICES += phicomm_k3|' target/linux/bcm53xx/image/Makefile


# 在线更新时，删除不想保留固件的某个文件，在EOF跟EOF之间加入删除代码，记住这里对应的是固件的文件路径，比如： rm -rf /etc/config/luci
cat >$DELETE <<-EOF
EOF


# 修改插件名字
sed -i 's/"aMule设置"/"电驴下载"/g' `egrep "aMule设置" -rl ./`
sed -i 's/"网络存储"/"NAS"/g' `egrep "网络存储" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `egrep "Turbo ACC 网络加速" -rl ./`
sed -i 's/"实时流量监测"/"流量"/g' `egrep "实时流量监测" -rl ./`
sed -i 's/"KMS 服务器"/"KMS激活"/g' `egrep "KMS 服务器" -rl ./`
sed -i 's/"TTYD 终端"/"命令窗"/g' `egrep "TTYD 终端" -rl ./`
sed -i 's/"USB 打印服务器"/"打印服务"/g' `egrep "USB 打印服务器" -rl ./`
sed -i 's/"Web 管理"/"Web管理"/g' `egrep "Web 管理" -rl ./`
sed -i 's/"管理权"/"改密码"/g' `egrep "管理权" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `egrep "带宽监控" -rl ./`



# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间（根据编译机型变化,自行调整删除的固件名称）
cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
openwrt-x86-64-generic-kernel.bin
openwrt-x86-64-generic.manifest
openwrt-x86-64-generic-squashfs-rootfs.img.gz
openwrt-x86-64-generic-rootfs.tar.gz
openwrt-x86-64-generic-ext4-rootfs.img.gz
sha256sums
version.buildinfo
EOF

# ADD by Mayos

# FEEDS
echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default
echo 'src-git sundaqiang https://github.com/sundaqiang/openwrt-packages-backup' >>feeds.conf.default


# Bash
sed -i "s/\/bin\/ash/\/bin\/bash/" package/base-files/files/etc/passwd >/dev/null 2>&1
sed -i "s/\/bin\/ash/\/bin\/bash/" package/base-files/files/usr/libexec/login.sh >/dev/null 2>&1

# SSH open to all
sed -i '/option Interface/s/^#\?/#/'  package/network/services/dropbear/files/dropbear.config

# OPKG
#sed -i 's#mirrors.cloud.tencent.com/lede#mirrors.tuna.tsinghua.edu.cn/openwrt#g' package/lean/default-settings/files/zzz-default-settings
#sed -i 's/x86_64/x86\/64/' /etc/opkg/distfeeds.conf
#sed -i "/kenzok8/d" /etc/opkg/distfeeds.conf
sed -i "/exit 0/i sed -i \"\/kenzo\/d\" \/etc\/opkg\/distfeeds.conf"        "${ZZZ_PATH}"
sed -i "/exit 0/i sed -i \"\/small\/d\" \/etc\/opkg\/distfeeds.conf"        "${ZZZ_PATH}"
sed -i "/exit 0/i sed -i \"\/passwall\/d\" \/etc\/opkg\/distfeeds.conf"     "${ZZZ_PATH}"
sed -i "/exit 0/i sed -i \"\/sundaqiang\/d\" \/etc\/opkg\/distfeeds.conf"   "${ZZZ_PATH}"
sed -i "/exit 0/i sed -i \"\/kiddin9\/d\" \/etc\/opkg\/distfeeds.conf"      "${ZZZ_PATH}"

# DIAG
sed -i "/uci commit system/a uci commit diag"                               "${ZZZ_PATH}"
sed -i "/uci commit diag/i uci set luci.diag.dns='jd.com'"                  "${ZZZ_PATH}"
sed -i "/uci commit diag/i uci set luci.diag.ping='jd.com'"                 "${ZZZ_PATH}"
sed -i "/uci commit diag/i uci set luci.diag.route='jd.com'"                "${ZZZ_PATH}"

# FW
sed -i "/uci commit luci/a uci commit firewall"                              "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.web=rule"                    "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.web.target='ACCEPT'"         "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.web.src='wan'"               "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.web.proto='tcp'"             "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.web.name='HTTP'"             "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.web.dest_port='80'"          "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ssh=rule"                    "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ssh.target='ACCEPT'"         "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ssh.src='wan'"               "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ssh.proto='tcp'"             "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ssh.dest_port='22'"          "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ssh.name='SSH'"              "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd=rule"                   "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd.target='ACCEPT'"        "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd.src='wan'"              "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd.proto='tcp'"            "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd.dest_port='7681'"       "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd.name='TTYD'"            "${ZZZ_PATH}"
sed -i "/uci commit firewall/i uci set firewall.ttyd.enabled='1'"            "${ZZZ_PATH}"

# DHCP
sed -i 's/100/11/g' package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/150/250/g' package/network/services/dnsmasq/files/dhcp.conf
