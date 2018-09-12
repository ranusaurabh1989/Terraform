#!/bin/bash

export KUBECONFIG=generated/KUBECONFIG

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000

python -mwebbrowser http://localhost:3000/dashboard/db/istio-mesh-dashboard