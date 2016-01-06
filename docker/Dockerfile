FROM 61.160.36.122:8080/sigmas/baseimage:0.9.18

CMD ["/sbin/my_init"]

RUN rm -f /etc/service/sshd/down
ADD id_rsa.pub /tmp/id_rsa.pub
RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.pub

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
