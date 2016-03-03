# Need some basic commands from busybox
FROM busybox
ADD pause /
RUN mkdir /init-data
RUN mkdir /shared-volume
ENTRYPOINT ["entrypoint.sh"]
