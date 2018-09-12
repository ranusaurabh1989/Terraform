#!/bin/bash

echo "Deleting fluentd and logging stack"

kubectl delete -f ~/fluentd-istio.yaml

kubectl delete -f ~/logging-stack.yaml

echo "Deleting Bookinfo"
cd /opt/istio-${istio_version}

kubectl delete -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml

echo "Deleting Istio"
helm delete istio --purge

kubectl delete -f install/kubernetes/helm/istio/templates/crds.yaml -n istio-system