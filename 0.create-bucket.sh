#!/bin/bash
set -eo pipefail
BUCKET_ID=$(dd if=/dev/random bs=8 count=1 2>/dev/null | od -An -tx1 | tr -d ' \t\n')
SNAPSHOT_BUCKET_ID=$(dd if=/dev/random bs=8 count=1 2>/dev/null | od -An -tx1 | tr -d ' \t\n')
BUCKET_NAME=lambda-artifacts-$BUCKET_ID
SNAPSHOT_BUCKET_NAME=snapshot-repo-$SNAPSHOT_BUCKET_ID
echo "$BUCKET_NAME" > bucket-name.txt
echo "$SNAPSHOT_BUCKET_NAME" >> bucket-name.txt
aws s3 mb s3://$BUCKET_NAME
aws s3 mb s3://$SNAPSHOT_BUCKET_NAME