#!/bin/bash
set -e
SET_CONTAINER_TIMEZONE=true
CONTAINER_TIMEZONE="Asia/Shanghai"

buildDeps="
  build-essential
  curl
  git
  libc6-dev
  libexpat1-dev
  libjpeg-dev
  libreadline-dev
  libssl-dev
  libxml2-dev
  libxslt-dev
  libxslt1-dev
  libyaml-dev
  libz-dev
  zlib1g-dev
  libaio1
  unzip
"

runDeps="
  curl
  libjpeg62
  libpng16-16
  libssl1.0-dev
  libxml2
  libxslt1.1
  libyaml-0-2
  lynx
  poppler-utils
  wv
  libaio1
  vim
"

echo "========================================================================="
echo "Installing $buildDeps"
echo "========================================================================="

apt-get update
apt-get install -y --no-install-recommends $buildDeps

echo "========================================================================="
echo "Ininstalling global paython packages"
echo "========================================================================="
pip install -i https://mirrors.aliyun.com/pypi/simple/ redis==2.10.5
pip install -i https://mirrors.aliyun.com/pypi/simple/ numpy==1.10.4
pip install -i https://mirrors.aliyun.com/pypi/simple/ bokeh==1.0.0
pip install -i https://mirrors.aliyun.com/pypi/simple/ cython pandas==0.17.1
pip install -i https://mirrors.aliyun.com/pypi/simple/ futures==3.0.4

echo "========================================================================="
echo "Ininstalling Oracle instant client"
echo "========================================================================="
mkdir -p /opt/oracle
cd /opt/oracle
mv /*.zip .
unzip instantclient-basic-linux.x64-19.8.0.0.0dbru.zip
unzip instantclient-sdk-linux.x64-19.8.0.0.0dbru.zip
sh -c "echo /opt/oracle/instantclient_19_8 > /etc/ld.so.conf.d/oracle-instantclient.conf"
ldconfig
export ORACLE_HOME=/opt/oracle/instantclient_19_8
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
rm -rf *.zip

echo "========================================================================="
echo "untar src.tgz"
echo "========================================================================="

cd /
tar -zxf src.tgz -C /plone/instance/
rm src.tgz

echo "========================================================================="
echo "setting timezone"
echo "========================================================================="

if [ "$SET_CONTAINER_TIMEZONE" = "true" ]; then
    echo ${CONTAINER_TIMEZONE} >/etc/timezone && \
    ln -sf /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
    echo "Container timezone set to: $CONTAINER_TIMEZONE"
else
    echo "Container timezone not modified"
fi

echo "Running buildout -c emc.cfg"
echo "========================================================================="
cd /plone/instance
buildout -vvv -c emc.cfg

echo "========================================================================="
echo "Unininstalling $buildDeps"
echo "========================================================================="

apt-get purge -y --auto-remove $buildDeps


echo "========================================================================="
echo "Installing $runDeps"
echo "========================================================================="

apt-get install -y --no-install-recommends $runDeps


echo "========================================================================="
echo "Cleaning up cache..."
echo "========================================================================="

rm -rf /var/lib/apt/lists/*
rm -rf /plone/buildout-cache/downloads/*
rm -rf /tmp/*
#mkdir for bokeh temp dir
mkdir -p  /data/tmp
# Fix permissions
find /data  -not -user plone -exec chown plone:plone {} \+
find /plone -not -user plone -exec chown plone:plone {} \+
