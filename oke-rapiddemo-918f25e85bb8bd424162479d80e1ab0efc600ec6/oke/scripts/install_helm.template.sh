#!/bin/bash

wget https://storage.googleapis.com/kubernetes-helm/helm-v${helm_version}-linux-amd64.tar.gz

tar zxvf helm-v${helm_version}-linux-amd64.tar.gz

sudo mv linux-amd64/helm /usr/local/bin

rm -rf linux-amd64

helm init --upgrade