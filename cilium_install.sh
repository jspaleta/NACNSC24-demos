#!/bin/bash
# Script can be run before or after seed.sh

CILIUM_VERSION="${CILIUM_VERSION:-v1.15.5}"


## Install Cilium
echo "This may take a few minutes for image pulls"
cilium install --version $CILIUM_VERSION -f ./cilium/cilium-helm-values.yaml 


