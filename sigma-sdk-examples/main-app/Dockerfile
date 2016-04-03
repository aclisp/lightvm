FROM 61.160.36.122:8080/lightvm:latest

# 安装进程可执行文件（由 myapp.go 编译）
COPY myapp ／

# 设置自动拉起进程
RUN mkdir /etc/service/myapp
COPY myapp.sh /etc/service/myapp/run
RUN chmod +x /etc/service/myapp/run

# The entrypoint of lightvm will start everything
# under `/etc/service` as daemon
