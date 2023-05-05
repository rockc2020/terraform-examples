#!/bin/bash -eu

WHEREAMI="$(dirname "$0")"
"$WHEREAMI"/migration-0.precheck.sh "$1"

# label all existing nodes
for NODE in $(kubectl get node --output=jsonpath={.items..metadata.name}); do
    LABELLED=$(kubectl get node $NODE -o json | jq '.metadata.labels | has("cni")')
    if [ "$LABELLED" = "true" ]; then
        LABEL_VALUE=$(kubectl get node $NODE -o json | jq -r '.metadata.labels.cni')
        echo "Node $NODE already labelled: cni=$LABEL_VALUE"
    else
        kubectl label nodes $NODE cni=aws
    fi
done

# verify all nodes are labelled
LABELLED_NODE_COUNT=$(kubectl get node -l cni=aws -o json | jq '.items | length')
ALL_NODE_COUNT=$(kubectl get node -o json | jq '.items | length')

if [ ! "$LABELLED_NODE_COUNT" = "$ALL_NODE_COUNT" ]; then
    echo "Not all nodes labelled."
    echo "Labelled nodes: $LABELLED_NODE_COUNT, total: $ALL_NODE_COUNT"
    exit 1
fi

echo "All nodes are labelled."
