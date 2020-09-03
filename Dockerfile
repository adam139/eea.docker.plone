FROM registry.cn-hangzhou.aliyuncs.com/plone/plone-debian:5.1.6
LABEL maintainer="www.315ok.org Tang Yuejun <568066794@qq.com>"

ENV GRAYLOG=logcentral.eea.europa.eu:12201 \
    GRAYLOG_FACILITY=eea.docker.plone

RUN mv /docker-entrypoint.sh /plone-entrypoint.sh \
 && mv /docker-initialize.py /plone_initialize.py \
 && mv /plone/instance/versions.cfg /plone/instance/plone-versions.cfg \
 && mv -v /plone/instance/buildout.cfg /plone/instance/plone-buildout.cfg

COPY src/docker/* /
COPY src/plone/* /plone/instance/
RUN /docker-setup.sh
