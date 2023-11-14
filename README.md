## More

See [流量监控Surge面板](https://github.com/getsomecat/GetSomeCats/blob/Surge/%E5%8F%A6%E4%B8%80%E4%B8%AAVPS%E6%B5%81%E9%87%8F%E7%9B%91%E6%8E%A7Surge%E9%9D%A2%E6%9D%BF.md)

## Start
```bash
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/durianice/serviceDataWatch/main/serviceDataWatch.sh)"
```

## Surge
```
#!name=CatVPS
#!desc=监控VPS流量信息和处理器、内存占用情况
#!author= 面板和脚本部分@Sestea @clydetime  VPS端部分 @Sestea 由 @整点猫咪 进行整理
#!howto=将模块内容复制到本地后根据自己VPS IP地址及端口修改 http://127.0.0.1:7122



[Panel]
Serverinfo = script-name= Serverinfo,update-interval=3600

[Script]
Serverinfo = type=generic,script-path=https://raw.githubusercontent.com/getsomecat/GetSomeCats/Surge/script/serverinfo.js, argument = url=http://127.0.0.1:7122&name=Server Info&icon=party.popper
```
