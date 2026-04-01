#!/bin/bash

TIMESTAMP=$(date "+%Y%m%d%H%M%S")
ARTIFACT="artifacts/build-$TIMESTAMP.tgz"
SHA_FILE="artifacts/build-$TIMESTAMP.sha256"

mkdir -p artifacts

tar -czf "$ARTIFACT" src logs

sha256sum "$ARTIFACT" > "$SHA_FILE"

echo "Artifact created: $ARTIFACT"
echo "Checksum saved to: $SHA_FILE"
