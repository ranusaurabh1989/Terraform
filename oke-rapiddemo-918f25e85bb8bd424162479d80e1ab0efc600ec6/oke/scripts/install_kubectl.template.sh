#!/bin/bash

sudo yum install -y kubectl git

sudo mkdir /home/opc/.kube

sudo chown -R opc:opc /home/opc/.kube
