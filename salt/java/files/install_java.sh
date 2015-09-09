#!/usr/bin/env bash
set -e

java=`command -v java || true`

if [[ -z ${java} ]]; then
    echo 'Java missing, installing...'
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz -O java-linux-x64.gz
    mkdir -p /usr/lib/jvm
    tar zxvf java-linux-x64.gz -C /usr/lib/jvm
    update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_45/bin/java" 1
    update-alternatives --set java /usr/lib/jvm/jdk1.8.0_45/bin/java
    echo 'Java installed!'
else
    echo 'Java already installed!'
fi