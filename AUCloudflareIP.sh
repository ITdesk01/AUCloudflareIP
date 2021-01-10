#!/bin/sh

#set -x
version="1.0"
Script_file="/usr/share/AUCloudflareIP"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
white="\033[0m"

	
start() {
	#添加系统变量
	checkjs_path=$(cat /etc/profile | grep -o AUCloudflareIP.sh | wc -l)
	if [ "$checkjs_path" == "0" ]; then
		echo "export AUCI_file=/usr/share/AUCloudflareIP" |  tee -a /etc/profile
		echo "export AUCI=/usr/share/AUCloudflareIP/AUCloudflareIP.sh" |  tee -a /etc/profile
		echo "-----------------------------------------------------------------------"
		echo ""
		echo -e "$green添加AUCI变量成功,重启系统以后无论在那个目录输入 sh \$AUCI 都可以运行脚本$white"
		echo ""
		echo ""
		echo -e "          $green直接回车会重启你的系统!!!，如果不需要马上重启ctrl+c取消$white"
		echo "-----------------------------------------------------------------------"
		read a
		reboot
	else
		echo ""
	fi

	cd  $Script_file
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
	
	./CloudflareST -n 1000 -sl 2 -p 1 -o result.txt
	
	if [ ! result.txt ]; then
		echo "文件为空，不做改变"
	else
		suansuan=$(cat old_ip.txt)
		new_ip=$(cat result.txt | awk -F '[ ,]+' 'NR==2 {print $1}')
		sed -i "s/$suansuan/$new_ip/g" /etc/config/shadowsocksr
		/etc/init.d/shadowsocksr restart
		echo -e "$green将旧IP:$white${suansuan}$green替换为新IP:$white${new_ip}$green,并重启酸酸$white"
		echo $new_ip > old_ip.txt

		cron_if=$(cat /etc/crontabs/root | grep "AUCloudflareIP" |wc -l)
		if [ $cron_if  = "1" ]; then
			echo ""		
		else
			echo "30 10 * * * /usr/share/AUCloudflareIP.sh >/tmp/AUCloudflareIP_update.log 2>&1" >>/etc/crontabs/root
			echo "45 10 * * * /usr/share/AUCloudflareIP.sh update_script >/tmp/AUCloudflareIP.log 2>&1" >>/etc/crontabs/root
			/etc/init.d/cron restart
		fi
	fi
}

update_script() {
	cd $Script_file
	git fetch --all
	git reset --hard origin/main
	chmod +x AUCloudflareIP.sh
	chmod +x CloudflareST
}


action1="$1"
if [ -z $action1 ]; then
	start
else
	case "$action1" in
			start|update_script)
			$action1
			;;
			*)
			echo "请不要乱输，我是不会执行的。。。"
			exit
			;;
esac
fi
