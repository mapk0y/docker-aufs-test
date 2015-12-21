# aufs で chmod を行った場合の挙動がおかしい件

### 概要

aufs 上でスクリプトファイルに `chmod -x` で実行権限を追加してそのまま実行すると「Text file busy」となる。以下、docker 上でテストを実施した場合で説明する。

```console
$ docker build -t aufs-test --no-cache .
Sending build context to Docker daemon 4.096 kB
Step 1 : FROM debian
---> 23cb15b0fcec
Step 2 : MAINTAINER mapk0y@gmail.com
---> Running in e6585eb6fc3b
---> e06d9da3642a
Removing intermediate container e6585eb6fc3b
Step 3 : COPY ./sample.sh /sample.sh
---> cc43e16546eb
Removing intermediate container 7dddb4cfe73c
Step 4 : RUN chmod +x /sample.sh && /sample.sh
---> Running in b6ca2419a530
/bin/sh: 1: /sample.sh: Text file busy
The command '/bin/sh -c chmod +x /sample.sh && /sample.sh' returned a non-zero code: 2
```

### overlay(fs) の場合どうなるか

#### boot2docker on vbox (docker-machine) の場合の設定変更方法

注意事項
- aufs から overlay(fs) に変更する場合、イメージは引き継がれません。
- イメージの削除もされないので aufs に戻さない場合は容量が無駄になりまる。

##### 設定の確認 - aufs

```console
$ docker info
Containers: 5
Images: 16
Server Version: 1.9.1
Storage Driver: aufs
 Root Dir: /mnt/sda1/var/lib/docker/aufs
  Backing Filesystem: extfs
  Dirs: 26
  Dirperm1 Supported: true
(snip)
```

##### 設定変更

```console
$ docker-machine ssh default 'sudo sed -i.bak -e "s/aufs/overlay/" /var/lib/boot2docker/profile && sudo /etc/init.d/docker restart'
Need TLS certs for default,127.0.0.1,10.0.2.15,192.168.99.100
-------------------
```

##### 設定の確認 - overlay(fs)

```console
$ docker info
Containers: 0
Images: 0
Server Version: 1.9.1
Storage Driver: overlay
 Backing Filesystem: extfs
```

##### overlay(fs)上で docker build した場合

```console
$ docker build -t aufs-test --no-cache .
Sending build context to Docker daemon 5.632 kB
Step 1 : FROM debian
 ---> 23cb15b0fcec
Step 2 : MAINTAINER mapk0y@gmail.com
 ---> Running in 49cc8f8223b6
 ---> 09561a508c0c
Removing intermediate container 49cc8f8223b6
Step 3 : COPY ./sample.sh /sample.sh
 ---> 36f602d75896
Removing intermediate container 29d62297a761
Step 4 : RUN chmod +x /sample.sh && /sample.sh
 ---> Running in 3bc8340ffb3e
foo
 ---> 8115440bdb4c
Removing intermediate container 3bc8340ffb3e
Successfully built 8115440bdb4c
```

### 原因

aufs の問題だと思うが不明
