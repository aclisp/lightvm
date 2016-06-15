# Need some basic commands from busybox
FROM busybox
ADD pause /
ADD entrypoint.sh /
ADD postStart.sh /
RUN mkdir /init-script
RUN mkdir /init-data
RUN mkdir /shared-volume
ENTRYPOINT ["/entrypoint.sh"]
