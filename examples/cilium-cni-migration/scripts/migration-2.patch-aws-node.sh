#!/bin/bash -eu

WHEREAMI="$(dirname "$0")"
"$WHEREAMI"/migration-0.precheck.sh "$1"

kubectl patch daemonset aws-node -n kube-system --patch "$(cat ${WHEREAMI}/aws-node-patch.yaml)"
