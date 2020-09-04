#!/bin/bash
set -e

buildDeps="
  build-essential
  curl
  git
  libc6-dev
  libexpat1-dev
  libjpeg-dev
  libpq-dev
  libreadline-dev
  libsasl2-dev
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
  ghostscript
  git
  graphviz
  gsfonts
  libjpeg62
  libpng16-16
  libpq5
  librsvg2-bin
  libssl1.0-dev
  libxml2
  libxslt1.1
  libyaml-0-2
  lynx
  poppler-utils
  tex-gyre
  vim
  wv
  libaio1
"

echo "========================================================================="
echo "Installing $buildDeps"
echo "========================================================================="

apt-get update
apt-get install -y --no-install-recommends $buildDeps

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
export $ORACLE_HOME = /opt/oracle/instantclient_19_8
export $LD_LIBRARY_PATH = $ORACLE_HOME:$LD_LIBRARY_PATH

echo "========================================================================="
echo "Running buildout -c buildout.cfg"
echo "========================================================================="
buildout -c buildout.cfg

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

echo "========================================================================="
echo "Fixing permissions..."
echo "========================================================================="

mkdir -p /data/log

touch /data/log/instance.log
touch /data/log/instance-Z2.log

touch /data/log/standalone.log
touch /data/log/standalone-Z2.log

touch /data/log/zeo_client.log
touch /data/log/zeo_client-Z2.log

touch /data/log/zeo_async.log
touch /data/log/zeo_async-Z2.log

touch /data/log/rel_async.log
touch /data/log/rel_async-Z2.log

touch /data/log/rel_client.log
touch /data/log/rel_client-Z2.log

# BBB - Backward compatibility
mkdir -p /plone/instance/var
rm -rf /plone/instance/var/log
ln -s /data/log /plone/instance/var/log
# BBB - end

# Fix permissions
find /data  -not -user plone -exec chown plone:plone {} \+
find /plone -not -user plone -exec chown plone:plone {} \+
