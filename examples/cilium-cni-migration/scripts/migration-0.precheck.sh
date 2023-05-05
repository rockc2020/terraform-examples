#!/bin/bash -eu

KUBECONFIG="$1"

REQUIRED_COMMANDS=("kubectl" "jq""aws")
for COMMAND in ${REQUIRED_COMMANDS[*]}; do
    if ! command -v $COMMAND &> /dev/null
    then
        echo "$COMMAND could not be found, please install it."
        exit 1
    fi
done

export KUBECONFIG="$KUBECONFIG"

# check kubeconfig context
echo "Target kubernetes cluster is $(kubectl config current-context)"
echo "Do you want to continue? [y/N]"
read answer
if [ ! "$answer" = "y" ]; then
    echo "Exit."
    exit 1
fi
