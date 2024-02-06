#!/bin/bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

helm upgrade --install ingress-nginx ingress-nginx \
	--repo https://kubernetes.github.io/ingress-nginx \
	--namespace ingress-nginx --create-namespace

helm repo add projectcalico https://docs.tigera.io/calico/charts
helm upgrade --install calico projectcalico/tigera-operator \
	--version v3.27.0 \
	-f helm-calico-values.yaml \
	--namespace tigera-operator \
	--create-namespace
