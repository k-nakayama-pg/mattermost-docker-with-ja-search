mattermost-docker-with-ja-search
==

![Mattermost](/img/logoHorizontal.png)

# 概要

DockerでMattermost(日本語全文検索対応)を構築するプロジェクトです。  
  
**※プロキシ環境で構築していたものから、プロキシ情報を一旦全て削除して持ってきただけの状態です。プロキシなし環境で動作するかまだ検証ができていません。**

# 使い方

`git clone` して `docker-compose up -d` でOKです。  
コンテナが以下のように作成されます。

```
# docker ps
CONTAINER ID        IMAGE                                                     COMMAND                  CREATED             STATUS              PORTS                                            NAMES
02c0945d8590        mattermost-docker_app                                     "/docker-entry.sh ma…"   4 days ago          Up 4 days           80/tcp                                           mattermost-docker_app_1
4ca0ae5da052        mattermost-docker_db                                      "docker-entrypoint.s…"   4 days ago          Up 4 days           5432/tcp                                         mattermost-docker_db_1
8a7e6610a561        mattermost-docker_web                                     "nginx -g 'daemon of…"   4 days ago          Up 4 days           0.0.0.0:80->80/tcp                               mattermost-docker_web_1
```

# フォルダ構造

```
./mattermost-docker
|-- app(MattermostアプリのDockerイメージ)
|-- db(Mattermostアプリが使用するpostgresのDockerイメージ)
|-- img
|-- web(NginxのDockerイメージ)
|-- README.md
`-- docker-compose.yml
```

# 要所解説

app、db、web の要所を解説します。

## app

https://github.com/mattermost/mattermost-docker を参考に作ってます。

### プロキシ設定

プロキシ設定はdocker-composeでenv(コンテナ実行時の環境変数)にも設定してます。リンクプレビューとかするときにプロキシを通るので。  
Dockerfileでconfig.jsonの `.ServiceSettings.AllowedUntrustedInternalConnections` にプロキシを設定していますが、これを設定しないとMattermostがプロキシと通信してくれません。
画面ではシステムコンソールのDeveloperのところに設定があります。

## db

Mattermostの日本語検索に対応するために結構いじってます。

### 日本語検索に対応するために参考にしたサイト

- https://github.com/mattermost/mattermost-server/issues/2159#issuecomment-206444074
  - 日本語検索こうやったら出来るよってissuesのコメントに書いてる。公式サイトでもココにリンク貼ってる。
- [DockerでPGroonga - わさっき - はてなダイアリー](http://d.hatena.ne.jp/takehikom/20180130/1517314577)
  - MeCabとIPADICを構築するのにめっちゃ参考になった！
  - リポジトリ：https://github.com/takehiko/docker-pgroonga
- [iquiw/pgroonga-on-postgres - Docker Hub](https://hub.docker.com/r/iquiw/pgroonga-on-postgres/)
  - textsearch_jaをビルドするのにpostgresの開発ライブラリ？が必要ってエラーでたけど、 `postgresql-server-dev-${PG_MAJOR}` でいけた！
  - リポジトリ：https://github.com/iquiw/docker-pgroonga-on-postgres

### 日本語検索対応

MeCabとか日本語検索するために必要なツールのインストールはDockerfileに書いてます。  
curlで毎回ダウンロードしてもよかったけど、重かったので事前にダウンロードしたやつを使ってます。

- MeCab(形態素解析エンジン)
  - サイト：http://taku910.github.io/mecab/
  - ダウンロードリンク：https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE
- IPADIC(MeCab用のIPA 辞書)
  - サイト：http://taku910.github.io/mecab/
  - ダウンロードリンク：https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM
- textsearch_ja(形態素解析を使用した日本語全文検索の、PostgreSQL組み込み型モジュール)
  - サイト：https://github.com/oknj/textsearch_ja
  - ダウンロードリンク：https://github.com/oknj/textsearch_ja/archive/textsearch_ja-9.6.0.tar.gz
 
textsearch_jaのextension(postgres拡張設定)はコンテナ起動時に `create extension if not exists textsearch_ja` で初回起動時に作ってます。  
（毎回作りたいけどどうすればいいか分からない・・・）

```
mattermost=# \dx
 List of installed extensions
     Name      | Version |   Schema   |                             Description
---------------+---------+------------+----------------------------------------------------------------------
 plpgsql       | 1.0     | pg_catalog | PL/pgSQL procedural language
 textsearch_ja | 9.6     | public     | Integrated Full-Text-Search for Japanese
 using morphological analyze
(2 rows)
```

デフォルトのテキスト検索設定はdocker-composeでコマンドに `postgres -c default_text_search_config=pg_catalog.japanese` を指定して設定しています。

```
mattermost=# show default_text_search_config;
 default_text_search_config
----------------------------
 pg_catalog.japanese
(1 row)
```

## web

https://docs.mattermost.com/install/config-proxy-nginx.html 参考に作ってます。
