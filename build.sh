#!/usr/bin/env bash

# set -x

PREREQ_FAILED=
ensure() {
    echo -ne "checking for ${1}... "
    if hash $1 2>/dev/null; then
        echo "FOUND"
    else
        PREREQ_FAILED=1 echo "NOT FOUND"
    fi
}

ensure curl
ensure sdc-imgadm
ensure vmadm # depended on by scripts in image-converter submodule

if $PREREQ_FAILED; then
    echo >&2 "Prerequisite check failed. Aborting"; exit 1;
fi

exit 0;

GITHUB_VERSION=2.10.3
GITHUB_IMAGE_NAME="github-enterprise-${GITHUB_VERSION}"
GITHUB_IMAGE_FILENAME="${GITHUB_IMAGE_NAME}.qcow2"
GITHUB_DOWNLOAD_URI="https://github-enterprise.s3.amazonaws.com/kvm/releases/${GITHUB_IMAGE_FILENAME}"

curl --retry 2 --fail -Ls -O $GITHUB_DOWNLOAD_URI

pushd image-converter
convert-image -i "../${GITHUB_IMAGE_FILENAME}" -n $GITHUB_IMAGE_NAME -o linux

# TODO: It might be nice to improve image-converter to take a
# desitination path here

mv *.json ..
mv *.gz ..

popd

# sdc-imgadm import -m ./github-enterprise-2.10.2-2017071022.json -f ./github-enterprise-2.10.2-2017071022.zfs.gz

sdc-imgadm import -m ./${MANIFEST} -f ./${IMAGE_FILE}

