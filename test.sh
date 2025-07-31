#!/usr/bin/env bash

# Test bootstrap script in docker

set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed"
    exit 1
fi

PROJECT_NAME="arch-bootstrap-test"

if [[ -z "${PROJECT_NAME}" ]]; then
    echo "Unable to determine project name"
    exit 1
fi

IMAGE_TAG="${PROJECT_NAME}"

docker build --rm --no-cache -t "${IMAGE_TAG}" .


docker run --rm -it "${IMAGE_TAG}" | tee test.log

docker rmi "${IMAGE_TAG}"
