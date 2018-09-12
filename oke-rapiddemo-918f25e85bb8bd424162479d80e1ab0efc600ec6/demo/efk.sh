#!/bin/bash

export KUBECONFIG=generated/KUBECONFIG

kubectl -n logging port-forward $(kubectl -n logging get pod -l app=kibana -o jsonpath='{.items[0].metadata.name}') 5601:5601

python -mwebbrowser http://localhost:5601/