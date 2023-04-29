#!/bin/bash
set -eo pipefail
LAMBDA_ARTIFACT_BKT=$(sed -n '1p' bucket-name.txt)
SNAP_REPO_BKT=$(sed -n '2p' bucket-name.txt)
rm -rf *.zip
cd function
pip3 install --target . -r requirements.txt
zip -r ../Opensearch-Manual-Snapshot.zip .
cd ..
aws s3 cp ./Opensearch-Manual-Snapshot.zip s3://$LAMBDA_ARTIFACT_BKT