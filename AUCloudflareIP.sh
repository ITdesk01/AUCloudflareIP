#!/bin/sh

#set -x
version="1.1"
cron_file="/etc/crontabs/root"
#获取当前脚本目录copy脚本之家
Source="$0"
while [ -h "$Source"  ]; do
    dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"
    Source="$(readlink "$Source")"
    [[ $Source != /*  ]] && Source="$dir_file/$Source"
done
dir_file="$( cd -P "$( dirname "$Source"  )" && pwd  )"

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

	
start() {
	if [ ! -x $dir_file/AUCloudflareIP.sh ];then
		echo "添加权限"
		chmod 755 $dir_file/AUCloudflareIP.sh
		chmod 755 $dir_file/CloudflareST
		sh $dir_file/AUCloudflareIP.sh
	fi
	task
	system_variable
	cd  $dir_file
	clear
	echo "----------------------------------------------"
	echo -e "$green AUCloudflareIP $version $white"
	echo "----------------------------------------------"
	echo -e "$green 当前时间：$white`date "+%Y-%m-%d %H:%M"`"
	if [ -f old_ip.txt ]; then
		echo ""		
	else
		read  -p "请输入你现在酸酸使用的IP或者域名：" suansuan
		echo $suansuan > old_ip.txt
	fi
	
	./CloudflareST -n 1000 -sl 1 -p 1 -dn 2 -o result.txt
	
	if [ ! result.txt ]; then
		echo "文件为空，不做改变"
	else
		suansuan=$(cat old_ip.txt)
		if_speed=$(cat result.txt | awk -F '[ ,]+' 'NR==2 {print $6}'| awk -F. '{print $1}')
		if [ $if_speed -ge "3" ];then
			new_ip=$(cat result.txt | awk -F '[ ,]+' 'NR==2 {print $1}')
			sed -i "s/$suansuan/$new_ip/g" /etc/config/shadowsocksr
			/etc/init.d/shadowsocksr restart
			echo -e "$green将旧IP:$white${suansuan}$green替换为新IP:$white${new_ip}$green,并重启酸酸$white"
			echo $new_ip > old_ip.txt
		else
			echo -e "$yellow IP速度太慢重新跑，休息5分钟重新跑$white"
			sleep 5m
			start
		fi
	fi
}

update_script() {
	cd $dir_file
	git fetch --all
	git reset --hard origin/main
}

task() {
	cron_version="1.5"
	if [[ `grep -o "AUCloudflareIP的定时任务$cron_version" $cron_file |wc -l` == "0" ]]; then
		echo "不存在计划任务开始设置"
		task_delete
		task_add
		echo "计划任务设置完成"
	elif [[ `grep -o "AUCloudflareIP的定时任务$cron_version" $cron_file |wc -l` == "1" ]]; then
			echo "计划任务与设定一致，不做改变"
	fi

}
task_add() {
cat >>/etc/crontabs/root <<EOF
#**********这里是AUCloudflareIP的定时任务$cron_version版本**********#
30 10 * * * $dir_file/AUCloudflareIP.sh update_script >/tmp/AUCloudflareIP_update.log 2>&1
45 10,19 * * * $dir_file/AUCloudflareIP.sh >/tmp/AUCloudflareIP.log 2>&1
######101##########请将其他定时任务放到底下########
EOF
/etc/init.d/cron restart
}
task_delete() {
	sed -i '/AUCloudflareIP/d' /etc/crontabs/root >/dev/null 2>&1
	sed -i '/#101#/d' /etc/crontabs/root >/dev/null 2>&1
}

ds_setup() {
	echo "AUCloudflareIP删除定时任务设置"
	task_delete
	echo "AUCloudflareIP删除全局变量"
	sed -i '/AUCloudflareIP/d' /etc/profile >/dev/null 2>&1
	. /etc/profile
	echo "AUCloudflareIP定时任务和全局变量删除完成，脚本不会自动运行了"
}

system_variable() {
	#添加系统变量
	auci_path=$(cat /etc/profile | grep -o AUCloudflareIP.sh | wc -l)
	if [ "$auci_path" == "0" ]; then
		echo "export AUCI_file=$dir_file" |  tee -a /etc/profile
		echo "export AUCI=$dir_file/AUCloudflareIP.sh" |  tee -a /etc/profile
		. /etc/profile
	fi
}



action1="$1"
if [ -z $action1 ]; then
	start
else
	case "$action1" in
			start|update_script|system_variable)
			$action1
			;;
			*)
			echo "请不要乱输，我是不会执行的。。。"
			exit
			;;
esac
fi
