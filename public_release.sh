#!/bin/bash

function help {
    usage
    echo -e "MANDATORY:"
    echo -e "  -r, --release        release git banch name\n"
    echo -e "  -h, --help           Prints this help\n"
    example
}
DST_DIR="rp-kickstarts"
GIT_PUBLIC="git@github.com:redpesk-infra/${DST_DIR}.git"
REDPESK_RELEASE=""

while [ "$1" != "" ];
do
   case $1 in
    -r | --release ) shift
        REDPESK_RELEASE=$1
        ;;
    -h | --help )
        help
        exit
        ;;
    *)
        echo "illegal option $1"
        help
        exit 1
        ;;
    esac
    shift
done

if [ -z "${REDPESK_RELEASE}" ]; then
    echo Missing REDPESK_RELEASE
    exit 1
fi

if [ ! -d "${DST_DIR}" ]; then
    git clone "${GIT_PUBLIC}"
    cd "${DST_DIR}" || exit 1
    git checkout -b "${REDPESK_RELEASE}" "origin/${REDPESK_RELEASE}"
else
    cd "${DST_DIR}" || exit 1
    git fetch --all
    git checkout "${REDPESK_RELEASE}"
    git reset --hard origin/"${REDPESK_RELEASE}"
fi

cat ../MAINTAINERS | grep -v "eric.lequer@iot.bzh" > ./MAINTAINERS

cp -r ../kickstarts/RedPesk/* ./ 

rm -fr archived


