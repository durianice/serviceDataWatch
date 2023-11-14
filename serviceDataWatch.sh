#!/bin/bash

# 检查是否以 root 用户运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本必须以 root 用户身份运行" 1>&2
   exit 1
fi

# 检查服务是否已经在运行
if systemctl is-active --quiet servertraffic.service; then
  echo -e "\e[33mServer Traffic Monitor service is already running. Exiting...\e[0m"
  exit 0
fi

# 更新和升级系统
apt update && apt upgrade -y

# 安装 Python3 和 pip 包管理器
apt install -y python3 python3-pip

# 安装依赖包
pip3 install psutil || pip3 install psutil --break-system-packages

# 编写监控程序
cat << 'EOF' > /root/servertraffic.py
#!/usr/bin/env python3
# Sestea

import http.server
import socketserver
import json
import time
import psutil

# The port number of the local HTTP server, which can be modified
port = 7122

class RequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

        # Limit the HTTP server to one request per second
        time.sleep(1)

        # Obtain CPU/MEM usage and network traffic info
        cpu_usage = psutil.cpu_percent()
        mem_usage = psutil.virtual_memory().percent
        bytes_sent = psutil.net_io_counters().bytes_sent
        bytes_recv = psutil.net_io_counters().bytes_recv
        bytes_total = bytes_sent + bytes_recv

        # Get UTC timestamp and uptime
        utc_timestamp = int(time.time())
        uptime = int(time.time() - psutil.boot_time())

        # Get the last statistics time
        last_time = time.strftime("%Y/%m/%d %H:%M:%S", time.localtime())

        # Construct JSON dictionary
        response_dict = {
            "utc_timestamp": utc_timestamp,
            "uptime": uptime,
            "cpu_usage": cpu_usage,
            "mem_usage": mem_usage,
            "bytes_sent": str(bytes_sent),
            "bytes_recv": str(bytes_recv),
            "bytes_total": str(bytes_total),
            "last_time": last_time
        }

        # Convert JSON dictionary to JSON string
        response_json = json.dumps(response_dict).encode('utf-8')
        self.wfile.write(response_json)

with socketserver.ThreadingTCPServer(("", port), RequestHandler, bind_and_activate=False) as httpd:
    try:
        print(f"Serving at port {port}")
        httpd.allow_reuse_address = True
        httpd.server_bind()
        httpd.server_activate()
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("KeyboardInterrupt is captured, program exited")
EOF

# 使 Python 脚本可执行
chmod +x /root/servertraffic.py

# 编写服务
cat << 'EOF' > /etc/systemd/system/servertraffic.service
[Unit]
Description=Server Traffic Monitor

[Service]
Type=simple
WorkingDirectory=/root/
User=root
ExecStart=/usr/bin/python3 /root/servertraffic.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 重新加载守护进程，启动服务并设置开机自启
systemctl daemon-reload
systemctl start servertraffic.service
systemctl enable servertraffic.service

# 打印命令提示
echo -e "\e[32mServer Traffic Monitor service installed and started.\e[0m"
echo -e "\e[34mTo start the service: \e[1msystemctl start servertraffic.service\e[0m"
echo -e "\e[34mTo stop the service: \e[1msystemctl stop servertraffic.service\e[0m"
echo -e "\e[34mTo enable service on boot: \e[1msystemctl enable servertraffic.service\e[0m"
echo -e "\e[34mTo disable service on boot: \e[1msystemctl disable servertraffic.service\e[0m"

# 打印服务状态
systemctl status servertraffic.service
