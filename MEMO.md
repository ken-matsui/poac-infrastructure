---
title: poacpm
tags: poacpm
author: matken11235
slide: false
---
## VPCから作成する

### VPCの作成
名前: p-vpc
IPv4 CIDR: 10.0.0.0/16
IPv6 CIDR: ブロック無し
テナンシー: デフォルト

### サブネットの作成
名前: p-vpc-subnet1, p-vpc-subnet2
VPC: p-vpc
アベイラリティーゾーン: ap-northeast-1a, ap-northeast-1c
CIDR: 10.0.0.0/24, 10.0.1.0/24

### インターネットゲートウェイ
名前: p-vpc-gateway
作成後．．．
上のVPCにアタッチで，p-vpcにアタッチ

### ルートテーブル
名前: p-vpc-rt
VPC: p-vpc
作成後．．．
ルート: 0.0.0.0/0, 先ほど作成したインターネットゲートウェイを選択
サブネットの関連付け: 先ほど作成したサブネット二つを選択

デフォルトで作成されたルートテーブルは削除する．
このルートテーブルを，上の，メインテーブルとして設定する．


## 次，EC2

OSは，Ubuntu Server

| 項目 | 内容 | 値 |
|:--|:--|:--|
| Number of Instance | 今回作成するインスタンス数 | 1 |
| Purchasing option | スポットという料金体系がオークション形式のインスタンスを使うか | オフ |
| Network | どのVPCを使うか | 前回作成したVPCを選択する |
| Subnet | VPC内のどのSubnetを使うか | 前回作成したAZ-AのSubnetを選択する |
| Auto-assign Public IP | グローバルIPを用いるか | enable |
| IAM role | IAMというAWSのアカウント管理を用いている場合、特定のアカウントにのみこのインスタンスを操作を許したければ設定する | None |
| Shutdown behavior | OSレベルでのシャットダウンをかけた場合の振る舞い。インスタンスを一時停止（stop）するか、そのまま復旧不可能な完全停止(termiante)するか。 | stop |
| Enable termination protection | アクシデントで完全停止するのを抑制するか。オンにした場合、このオプションをいじらない限り完全停止できない。 | オフ |
| Monitoring | CloudWatchというAWSの監視サービスを使うか。 | オフ |
| Tenancy | ハードウェアを専有するか。専有する場合、料金アップ | Shared tenancy |


## SSHする

```
$ ssh poacpm
$ sudo apt install nginx
$ sudo /etc/init.d/nginx start
```

## 次，load balancer
https://qiita.com/hiroshik1985/items/ffda3f2bdb71599783a3

だいたいこれの通り！

## SSHする
```
$ ssh poacpm
$ sudo vim /etc/nginx/conf.d/default.conf
$ sudo rm -rf /etc/nginx/sites-enabled/default
```

`rm`しているのは，tempファイルがルーティングの邪魔をするから．
https://stackoverflow.com/questions/11426087/nginx-error-conflicting-server-name-ignored


```:/etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        if ($http_x_forwarded_proto = http) {
                return 301 https://$host$request_uri;
        }
        proxy_pass http://127.0.0.1:4000;
        #root   /usr/share/nginx/html;
        #index  index.html index.htm;
    }
}
```

```
$ sudo /etc/init.d/nginx restart
```

```
$ sudo apt update
$ sudo apt -y upgrade
$ sudo apt -y dist-upgrade
$ sudo apt install -y zsh
$ which zsh
$ sudo vim /etc/passwd
```

```:/etc/passwd
user:x:1001:1002::/home/user:/usr/bin/zsh
```

```
$ zsh
% git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
% setopt EXTENDED_GLOB
% for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
for> sudo ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
for> done
```

一旦ログアウトし，再起動し，再度SSH

```
$ sudo apt install awscli
$ aws configure
AWS Access Key ID [None]: 
AWS Secret Access Key [None]:
Default region name [None]: ap-northeast-1
Default output format [None]:
$ sudo apt install -y make inotify-tools

$ wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
$ sudo dpkg -i erlang-solutions_1.0_all.deb
$ sudo apt update
$ sudo apt upgrade -y
$ sudo apt install -y erlang

$ git clone https://github.com/mururu/exenv.git $HOME/.exenv
$ git clone https://github.com/mururu/elixir-build.git ~/.exenv/plugins/elixir-build
$ echo 'export PATH="$HOME/.exenv/bin:$PATH"' >> ~/.zshrc
$ echo 'eval "$(exenv init -)"' >> ~/.zshrc
$ source ~/.zshrc

$ exenv install --list
$ exenv install 1.5.1
$ exenv global 1.5.1

$ git clone https://github.com/creationix/nvm.git ~/.nvm
$ echo '# nvm' >> ~/.zshrc && echo 'if [[ -s ~/.nvm/nvm.sh ]]; then' >> ~/.zshrc && echo '  source ~/.nvm/nvm.sh' >> ~/.zshrc && echo 'fi' >> ~/.zshrc
$ source ~/.zshrc
$ nvm ls-remote
$ nvm install v8.9.4
$ npm install -g npm

$ mix local.hex
$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez

$ mkdir service
$ cd $_
$ mix phx.new test --no-ecto
$ cd test
$ mix phx.server
```


# Localの設定とか，継続的インテグレーションの設定
## 設定の後追い
```
$ mix local.hex
$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez
$ mix phx.new poacpm --no-ecto
$ cd poacpm
$ mix phx.server
ctr + \
$ git init
$ git add .
$ git commit -m 'first commit'
$ git remote add origin git@github.com:poacpm/poacpm.git
$ git push origin master
```

### AWS CodeCommit
poacpmリポジトリの作成
接続タイプを`HTTPS`とする．

IAMユーザーに設定する．
`AWS CodeCommit の HTTPS Git 認証情報`
より，生成を選択し，記録しておく．

下記コマンドでoriginにさらに追加する．
このことにより，`git push origin master`とするだけで，両方にpushされる．

```
$ git remote set-url --add origin https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/poacpm
$ git remote -v
origin	git@github.com:poacpm/poacpm.git (fetch)
origin	git@github.com:poacpm/poacpm.git (push)
origin	https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/poacpm (push)
$ git push origin master
Everything up-to-date
Username for 'https://git-codecommit.ap-northeast-1.amazonaws.com': matken-at-308453953340
Password for 'https://matken-at-308453953340@git-codecommit.ap-northeast-1.amazonaws.com':
Counting objects: 67, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (56/56), done.
Writing objects: 100% (67/67), 75.85 KiB | 2.30 MiB/s, done.
Total 67 (delta 1), reused 0 (delta 0)
To https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/poacpm
 * [new branch]      master -> master
```
