# See https://github.com/aclisp/baseimage-docker for this base image.
FROM 61.160.36.122:8080/sigmas/baseimage:0.9.18

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install yy-specific components.
ADD yy_build /yy_build
RUN /yy_build/config.sh

# Enable SSH and add a default public key.
RUN rm -f /etc/service/sshd/down
ADD id_rsa.pub /tmp/id_rsa.pub
RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys && rm -f /tmp/id_rsa.pub

# Run scripts during container startup.
RUN mkdir -p /etc/my_init.d
ADD my_init.d/*.sh /etc/my_init.d/

# Change root home to /data
RUN mkdir -p /data && \
    cp -R /root/. /data && \
    sed -i "s#^\(root:[^:]*:[^:]*:[^:]*:[^:]*:\)[^:]*\(:[^:]*\)#\1/data\2#" /etc/passwd

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
