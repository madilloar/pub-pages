# wsl2をつかえるようにする
```
wsl --set-version Ubuntu-20.04 2
wsl -l -v
```

# Dockerを使えるようにする
https://docs.docker.com/engine/install/ubuntu/

# Dockerインストール後にやること
https://docs.docker.com/engine/install/linux-postinstall/

```
sudo service docker start
```

``` 
curl -L https://github.com/docker/compose/releases/download/2.6.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```

# Dockerfileなどをダウンロード

```
curl -L https://github.com/oracle/docker-images/archive/refs/heads/main.zip --output main.zip
```

# ビルド

```
./buildContainerImage.sh -v 18.4.0 -x -i
```

OTNからエンタープライズ版インストールイメージのZIPファイルをダウンロード。
[OTNからダウンロード](https://www.oracle.com/webapps/redirect/signon?nexturl=https://download.oracle.com/otn/linux/oracle19c/190000/LINUX.X64_193000_db_home.zip)

```
cp /mnt/c/users/madilloar/downloads/LINUX.X64_193000_db_home.zip ~/prj/DB/oracle/docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0
./buildContainerImage.sh -v 19.3.0 -e -i
```

# セットアップ
## ホストOS側でoracleユーザとグループを作成

```
sudo groupadd -g 54321 oracle
sudo useradd -u 54321 -g oracle oracle
mkdir -p ~/prj/ora-db/oracle_data
sudo chown -R oracle:oracle ~/prj/ora-db/oracle_data
```
## docker-compose.ymlの作成

```docker-compose.yml:yml
version: '3.7'
services:
  oracle:
    image: oracle/database:18.4.0-xe
    volumes:
      ##- nm_ora_data:/opt/oracle/oradata
      - ./oracle_data:/opt/oracle/oradata
    environment:
      - TZ=Asia/Tokyo
      - ORACLE_PWD=myoracle
## TILDEがポイント。これを入れれば0x8160:～が文字化けしない。
      - ORACLE_CHARACTERSET=JA16SJISTILDE
    ports:
      - 1521:1521
## named volume
##volumes:
##  nm_ora_data:
```

# 起動と停止

```
docker-compose up -d
docker-compose down
```

# ログ参照

```
docker logs -f ora-db_oracle_1
```

# 実行中コンテナにrootで入る

```
docker exec -it --user root ora-db_oracle_1 bash -p
```

# ユーザ登録

```
docker exec -it --user oracle ora-db_oracle_1 bash -p
cd
sqlplus / as sysdba
show con_name

select pdb_name from cdb_pdbs
/

alter session set container=ORCLPDB1
/

create user a001
identified by "a001"
default tablespace users
temporary tablespace temp
/
grant unlimited tablespace to a001
/
grant create session to a001
/
grant create table to a001
/
grant create procedure to a001
/
grant create sequence to a001
/
grant create synonym to a001
/
grant create view to a001
/


create user d001
identified by "d001"
default tablespace users
temporary tablespace temp
/
grant unlimited tablespace to d001
/
grant create session to d001
/
grant create table to d001
/
grant create procedure to d001
/
grant create sequence to d001
/
grant create synonym to d001
/
grant create view to d001
/

```

# data pump
## セットアップ

```
docker exec -it --user root ora_db_oracle_1 bash -p
su oracle
mkdir /opt/oracle/oradata/datapump
sqlplus / as sysdba
alter session set container=ORCLPDB1;

create or replace directory DIR_DATA_PUMP as '/opt/oracle/oradata/datapump'
/
grant read on directory DIR_DATA_PUMP to a001
/
grant write on directory DIR_DATA_PUMP to a001
/
grant read on directory DIR_DATA_PUMP to d001
/
grant write on directory DIR_DATA_PUMP to d001
/
select * from all_directories
where
directory_name = 'DIR_DATA_PUMP'
/

```

## expdp

```
expdp d001/d001@ORCLPDB1 directory='DIR_DATA_PUMP' dumpfile=exp.dmp schemas=d001 logfile=export.log
```

## impdp

```
impdp d001/d001@ORCLPDB1 directory='DIR_DATA_PUMP' dumpfile=exp.dmp schemas=d001 logfile=import.log table_exists_action=truncate
```

## impdp 異なるDBから出力したdmpファイルのインポート

```
impdp d001/d001@ORCLPDB1 directory='DIR_DATA_PUMP' dumpfile=other_system_d001.dmp read_schema=d001:d001 remap_tablespace=OTHER_DATA001:USERS,OTHER_INDEX001:USERS logfile=import.log table_exists_action=truncate
```


## パスワード変更
```chpwd.sql
WHENEVER SQLERROR EXIT 16 ROLLBACK
WHENEVER OSERROR EXIT 16 ROLLBACK
SET ECHO ON
SET VERIFY ON
SET HEADING ON
SET TIME ON
SET TRIMOUT ON
SET TRIMSPOOL ON
SET TERMOUT ON
SET PAGESIZE 1000
SET LINESIZE 1000

SPOOL chpwd.log APPEND

-- ALTER USER 'youre user name' IDENTIFIED BY 'new password' REPLACE 'old password'


CONN D001/D001@XEPDB1
EXECUTE DBMS_SESSION.SET_IDENTIFIRE('CHANGE PASSWORD')
SELECT USER_NAME, EXPIRY_DATE FROM USER_USERS;
ALTER USER D001 IDENTIFIED BY 'D002' REPLACE 'D001'
SELECT USER_NAME, EXPIRY_DATE FROM USER_USERS;
DISCONNECT

QUIT
```

# tnsnames.ora

``%HOMEDRIVE%%HOMEPATH%\tnsnames.ora``

```
XEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XEPDB1)
    )
  )
```

# vmmemのメモリ使いすぎ問題対処
``%HOMEDRIVE%%HOMEPATH%\.wslconfig``

```
[wsl2]
memory=3GB
```
