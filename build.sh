#!/usr/bin/env bash

##########################

VERSION=2.10.3
IMAGE_NAME="github-enterprise-${VERSION}"
SOURCE_IMAGE_FILENAME="${IMAGE_NAME}.qcow2"
DOWNLOAD_URI="https://github-enterprise.s3.amazonaws.com/kvm/releases/${SOURCE_IMAGE_FILENAME}"

##########################

set -x

START_DATE=`date -u +"%Y%m%dT%H%M%SZ"`
PWD=`pwd`
log() {
    NOW=`date -u +"%Y%m%dT%H%M%SZ"`
    MSG="${NOW} ${1}"
    echo $MSG >> ${PWD}/build-${START_DATE}.log
    if [ ! $2 == "no" ]; then
        echo $MSG
    fi
}

PREREQ_FAILED="0"
ensure() {
    PREFIX="checking for ${1}..."
    if hash $1 2>/dev/null; then
        log "${PREFIX} FOUND"
    else
        PREREQ_FAILED="1"
        log "${PREFIX} NOT FOUND"
    fi
}

ensure curl
ensure sdc-imgadm
ensure vmadm # depended on by scripts in image-converter submodule

if [ "$PREREQ_FAILED" == "1" ]; then
    log "Prerequisite check failed. Aborting" no;
    echo >&2 "Prerequisite check failed. Aborting"; exit 1;
fi

log "Downloading image ${DOWNLOAD_URI}..."

curl --insecure --retry 2 -O $DOWNLOAD_URI

read -n 1 -s -r -p "Press any key to convert image"

log "Converting source image ${SOURCE_IMAGE_FILENAME} to ${IMAGE_NAME}..."

pushd image-converter

# remove any existing manifests and converted images
rm -f ./*.json
rm -f ./*.gz

./convert-image -i "../${SOURCE_IMAGE_FILENAME}" -n $IMAGE_NAME -o linux

MANIFEST_FILENAME=`ls -1 *.json | head -n 1`
IMAGE_FILENAME=`ls -1 *.gz | head -n 1`

# TODO: It might be nice to improve image-converter to take a
# desitination path here

mv ./*.json ..
mv ./*.gz ..

popd

# sdc-imgadm import -m ./github-enterprise-2.10.2-2017071022.json -f ./github-enterprise-2.10.2-2017071022.zfs.gz

read -n 1 -s -r -p "Press any key to import image"

log "Importing image ${IMAGE_FILENAME} with manifest ${MANIFEST_FILENAME}"

sdc-imgadm import -m ./${MANIFEST_FILENAME} -f ./${IMAGE_FILENAME}

log "Finished!"