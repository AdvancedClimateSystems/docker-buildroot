#!/bin/sh
# Modify root filesystem so it can be imported in docker.
#
# Almost a copy from script used in this post:
# https://blog.docker.com/2013/06/create-light-weight-docker-containers-buildroot/
set -e

if [ "$#" -ne 1 ] || [ ! -f $1 ]; then  
    echo "Provide path to a root filesystem."
    exit 1
fi

rm -rf /tmp/extra

mkdir /tmp/extra /tmp/extra/etc /tmp/extra/sbin /tmp/extra/lib /tmp/extra/lib64
touch /tmp/extra/etc/resolv.conf
touch /tmp/extra/sbin/init

cp /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libc.so.6 /tmp/extra/lib
cp /lib64/ld-linux-x86-64.so.2 /tmp/extra/lib64
cp $1 /tmp/fixup.tar

tar rvf /tmp/fixup.tar -C /tmp/extra .

docker import - dietfs < /tmp/fixup.tar
docker run --rm -ti dietfs /bin/sh
