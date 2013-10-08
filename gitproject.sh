#!/bin/bash

# カレントディレクトリをサーバに bare リポジトリとして用意するスクリプト
# 処理概要
# 1) サーバに
#
# usage: sharegitproj.sh [-u <username>]

# サーバ設定
SERVER=casagrande24.net
GITROOT=srv/git

# カレントディレクトリのチェック


# オプション解析


echo "current directory is $PWD"
DIRNAME=$(basename $PWD)
echo "basname is $DIRNAME"
USERNAME=$(whoami)
echo "username is $USERNAME"

# ユーザ確認を行う
echo "creating ssh://$USERNAME@$SERVER/$GITROOT/$DIRNAME.git"
cat <<END_OF_MESSAGE
1st step: [SERVER       ] create ssh://$USERNAME@$SERVER/$GITROOT/$DIRNAME.git
#2nd step: [LOCAL        ] initialize current directory as git repository.
3rd step: [LOCAL->SERVER] upload contents of current directory to server.
END_OF_MESSAGE
read -p "Are you sure?(yes/no)"
if [[ ! "$REPLY" == "yes" ]]; then
    echo "Abort."
    exit
fi

# サーバ側にリポジトリを用意
# 

#ssh -T ${USERNAME}@casagrande24.net <<REMOTE_COMMANDS
# cd /srv/git
# if [[ -d $DIRNAME ]]; then
#   exit 1
# fi
# mkdir $DIRNAME.git
# cd $DIRNAME.git
# git --bare init
# exit 0
#REMOTE_COMMANDS

if [[ $? -ne 0 ]]; then
    echo "error has occured."
    exit
fi

echo "created ssh://$USERNAME@$SERVER/$GITROOT/$DIRNAME.git"

cat <<EOF
echo "basname is $DIRNAME"
EOF


# 
# クライアント側を git 管理下におく
# 
# 既にプロジェクトは Test ディレクトリ以下にある前提。
# まず Test ディレクトリを git のワークディレクトリにする。
# 
# $ cd Test
# $ git init
# $ git add .
# $ git commit
# 
# 次にサーバに格納する。
# 
# $ git remote add origin ssh://ohya@casagrande24.net/srv/git/Test.git
# $ git push origin master
