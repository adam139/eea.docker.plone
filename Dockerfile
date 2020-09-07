FROM registry.cn-hangzhou.aliyuncs.com/plone/plone-debian:5.1.6
LABEL maintainer="www.315ok.org Tang Yuejun <568066794@qq.com>"


RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
 && sed -i "s@http://security.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list

COPY src/docker/* /
COPY src/plone/emc.cfg /plone/instance/
RUN /docker-setup.sh
