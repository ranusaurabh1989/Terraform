#!/bin/bash

export KUBECONFIG=generated/KUBECONFIG

kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686

python -mwebbrowser http://localhost:16686/