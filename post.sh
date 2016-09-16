#!/bin/bash

VERSION="v0.0.1"
VERBOSE=false

DATE=`date +%Y-%m-%d`
TITLE=""
FILE_NAME=""

function usage {
cat <<EOF

Usage: ./post.sh "hello-posting" 

SYNOPSIS:
    post.sh title
    post.sh [-t TITLE] 

DESCRIPTION:
    title              포스팅 타이틀
    -t --title         포스팅 타이틀
    -h --help          도움말
    -v --verbose       작업보기
    --version          버전표시
EOF
}

function version {
cat <<EOF
VERSION: $VERSION
EOF
}


while [ "$1" != "" ]; do
    case "$1" in
        -h | --help ) usage; exit 0;; 
        -v | --verbose ) VERBOSE=true;;
             --version ) version; exit 0;; 
        -t | --title ) shift; TITLE="$1";;
        * ) TITLE=$1;;
    esac
    shift;
done


no_space_title=`echo "${TITLE}" | sed -e 's/ /-/g'`
FILE_NAME=${DATE}-${no_space_title}.md

cp "$PWD/_templates/template.md" "$PWD/_posts/${FILE_NAME}"

if [ $VERBOSE ]
then
    echo "created _posts/$FILE_NAME"
fi

