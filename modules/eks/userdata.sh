#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${EKS_CLUSTER_ENDPOINT}' --b64-cluster-ca '${EKS_CLUSTER_CERTIFICATE_AUTHORITY}' '${EKS_CLUSTER_NAME}'
