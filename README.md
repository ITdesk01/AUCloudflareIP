# 不再维护下一步看看删除掉


# AUCloudflareIP
调用https://github.com/XIU2/CloudflareSpeedTest 得到新的IP，并自动替换openwrt上的酸酸地址


## 支持系统
openwrt X86 （基于x86测试）

## Usage 使用方法
```sh
git clone https://github.com/ITdesk01/AUCloudflareIP.git /usr/share/AUCloudflareIP
cd /usr/share/AUCloudflareIP && chmod +x AUCloudflareIP.sh
sh AUCloudflareIP.sh
```

## 二次调用

sh $AUCI        #调用脚本
sh $AUCI_file   #进入脚本所在目录


## 问题
1.如何重新出现“请输入你现在酸酸使用的IP或者域名：“这句提示
答：删除/usr/share/AUCloudflareIP/old_ip.txt ,重新执行脚本即可


