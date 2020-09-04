FROM registry.cn-hangzhou.aliyuncs.com/plone/plone-debian:5.1.6
LABEL maintainer="www.315ok.org Tang Yuejun <568066794@qq.com>"


#RUN mv /plone/instance/versions.cfg /plone/instance/plone-versions.cfg \
# && mv -v /plone/instance/buildout.cfg /plone/instance/plone-buildout.cfg \
RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list \
 && sed -i "s@http://security.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list

COPY src/docker/* /
COPY src/plone/emc.cfg /plone/instance/
RUN /docker-setup.sh
