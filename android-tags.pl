#!/bin/bash

# AndroidManifest.xml、src ディレクトリの存在を確認する
# gen やその他のソースは無視したい

# 対象とするディレクトリ
# src/ res/
#
# 対象とするソースファイルのサフィックス
# .c .cpp .h .hpp .java .xml

# usage: android-tags [-u]

#if (( $# == 0 )); then
#    echo "usage: android-tags [FILE|DIR] ..."
#    exit
#fi

NEWLIST=.tagfiles
OLDLIST=.tagfiles_prev

# オプション解析
while getopts "u" flag; do
    case $flag in
        \?) OPT_ERROR=1; break;;
        u) opt_u=1;;
    esac
done

if [[ $OPT_ERROR == 1 ]]; then
    echo "Usage: android-tags [-u]"
    exit
fi

shift $(( $OPTIND - 1 ))

MANIFEST=AndroidManifest.xml

# Android プロジェクトとして期待するファイル・ディレクトリ構成
# であることをチェック
if [[ ! -f $MANIFEST ]]; then
    echo "No such file: $MANIFEST"
    exit
fi

for dir in src res; do
    if [[ ! -d $dir ]]; then
        echo "No such directory: $dir"
        exit
    fi
done

# オプション -u が指定されたときは強制的にアップデートを行う
if [[ $opt_u == 1 ]]; then
    echo "### force update"
    rm -f $NEWLIST
fi

# タグを作成する対象ソースファイルをリストアップする
echo "listing source files..."

GREP_PATTERN="-e .c$ -e .cpp$ -e .h$ -e .hpp$ -e .java$ -e .xml$"

if [[ -f $NEWLIST ]]; then
    mv -f $NEWLIST $OLDLIST
fi

echo $MANIFEST > $NEWLIST

for dir in src res; do
  echo "find $dir -type f -print | fgrep $GREP_PATTERN >> $NEWLIST"
  find $dir -type f -print | egrep $GREP_PATTERN >> $NEWLIST
done

# 対象ファイルに変更がなければ更新不要と判断して終了
if [[ -f $OLDLIST ]]; then
    while read target; do
        echo "+++ $target"
        if [[ $target -nt $OLDLIST ]]; then
            UPDATED=1
            break
        fi
    done < $NEWLIST
    if [[ $UPDATED -ne 1 ]]; then
        echo "No files are updated. exit."
        mv -f $OLDLIST $NEWLIST
        exit
    fi
fi

rm -f $OLDLIST

# リストアップしたファイルについてタグファイルを作成する
echo "--- ctags ---"
ctags -L $NEWLIST

echo "--- gtags ---"
gtags -f $NEWLIST

echo "--- cscope ---"
cscope -b -i $NEWLIST

echo "--- rtags ---"
rtags tags
