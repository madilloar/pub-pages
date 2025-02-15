# PostgreSQLあれこれ覚書

## ローカルPCにPostgreSQLサーバとやり取りするフォルダを事前に作る
```bash
mkdir data
```

## docker-compose.yml
```YAML
version: '3.7'
services:
  my-posgre-db:
    image: postgres:latest
    volumes:
      - ./data:/var/lib/postgresql/data
    environment:
      - TZ=Asia/Tokyo
      - POSTGRES_PASSWORD=postgres
    networks:
        - my-posgre-network
    ports:
      - 5432:5432

networks:
  my-posgre-network:
    driver: bridge
```

## dockerでpsqlを動かしてPostgreSQLサーバに接続する
```bash
docker run -it --rm -v ./work:/tmp --network postgresql_my-posgre-network postgres:latest psql -h  my-posgre-db -U postgres
```

- ``-it``: ''i''がコンテナの標準入力にローカルから入力できりょうにして、``t``が疑似ターミナルを割り当てている。
- ``-v ./work:tmp``: ローカルのカレントディレクトリの``work``ディレクトリと``psql``コマンドを動かしているコンテナの``/tmp``ディレクトリを接続している。
- ``--network postgresql_my-posgre-network``: ``psql``コマンドが接続するネットワークを指定。docker-composeに記述しているもの。接頭辞に``postgresql_``が付いているのは、``docker-compose.yml``ファイルが存在しているディレクトリが``postgresql_``のため。
- ``postgres:latest``: 起動するコンテナイメージ
- ``psql``: 起動したコンテナイメージの中にある``psql``コマンド
- ``-h my-postgre-db``: YAMLファイルに書いているサービスの名前「my-postgre-db」
- ``-U postgres``: DBに接続する際のユーザID


## psqlコマンドあれこれ
### 現在接続しているデータベース
```sql
\conninfo
```

### データベース一覧
```sql
\l
```

### テーブル一覧
```sql
\dt *
```

### データベース接続
```sql
\c <データベース名>
```
### SELECTクエリの結果をファイルに出力
この例では/tmpディレクトリに出力している。上記の [dockerでpsqlを動かしてPostgreSQLサーバに接続する](#dockerでpsqlを動かしてPostgreSQLサーバに接続する) 際に``-v``オプションで``/tmp``ディレクトリをローカルPCのディレクトリに接続していれば、ローカルPCにresult.txtが作られる。
```
\COPY (SELECT * FROM your_table) TO '/tmp/result.txt' WITH CSV HEADER;
```
