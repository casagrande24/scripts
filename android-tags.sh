#!/bin/bash
#-----------------------------------------------------------------------------
# Android Project のタグファイル生成スクリプト
#-----------------------------------------------------------------------------
#
# 生成するタグファイル、クロスリファレンス:
#   ctags, gtags, cscope, rtags
#   
# 検索対象ディレクトリ:
#   src/ res/ jni/
#
# 対象とするソースファイルのサフィックス:
#   .c .cpp .h .hpp .java .xml
#
# Usage:
#   android-tags [-f]
#
# Options:
#   -f   強制アップデート

#-----------------------------------------------------------------------------
# ファイルリスト名定義
NEWLIST=.tagfiles
OLDLIST=.tagfiles_prev

# オプション解析
while getopts "f" flag; do
    case $flag in
        \?) OPT_ERROR=1; break;;
        f) opt_f=1;;
    esac
done

if [[ $OPT_ERROR == 1 ]]; then
    echo "Usage: android-tags [-f]"
    exit
fi

shift $(( $OPTIND - 1 ))

# Android プロジェクトとして期待するファイル・ディレクトリ構成
# であることをチェック
MANIFEST=AndroidManifest.xml

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

for dir; do
    if [[ ! -d $dir ]]; then
        echo "No such directory: $dir"
        exit
    fi
done

# オプション -f が指定されたときは強制的にアップデートを行う
if [[ $opt_f == 1 ]]; then
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

for dir in src res jni; do
    if [[ -d $dir ]]; then
        echo "find $dir -type f -print | egrep $GREP_PATTERN >> $NEWLIST"
        find $dir -type f -print | egrep $GREP_PATTERN >> $NEWLIST
    fi
done

for dir; do
    echo "find $dir -type f -print | egrep $GREP_PATTERN >> $NEWLIST"
    find $dir -type f -print | egrep $GREP_PATTERN >> $NEWLIST
done

# 旧リストファイルの作成以降に更新されたファイルがひとつも無ければタグは更新不要と判断して終了
if [[ -f $OLDLIST ]]; then
    while read target; do
        echo "+++ $target"
        if [[ $target -nt $OLDLIST ]]; then
            echo "+++ $target has been updated since last run. +++"
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

# リストアップしたファイル群に対するタグファイルを作成する
echo "--- ctags ---"
ctags -L $NEWLIST

echo "--- gtags ---"
gtags -f $NEWLIST

echo "--- cscope ---"
cscope -b -i $NEWLIST

echo "--- rtags ---"
rtags tags
