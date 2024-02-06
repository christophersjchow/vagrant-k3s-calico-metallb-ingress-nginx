#!/bin/bash

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install Calico
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm upgrade --install calico projectcalico/tigera-operator \
	--version v3.27.0 \
	-f helm-calico-values.yaml \
	--namespace tigera-operator \
	--create-namespace \
	--wait

# Enable Wireguard in Calico for in-cluster encryption
kubectl patch felixconfiguration default --type='merge' -p '{"spec":{"wireguardEnabled":true}}'

# Install Metallb
helm repo add metallb https://metallb.github.io/metallb
helm upgrade --install metallb metallb/metallb \
	--namespace metallb-system \
	--create-namespace \
	--wait \
	--debug
kubectl apply -f metallb-pool.yaml

# Install ingress-nginx last as it requires an LB to become healthy
helm upgrade --install ingress-nginx ingress-nginx \
	--repo https://kubernetes.github.io/ingress-nginx \
	--namespace ingress-nginx --create-namespace \
	--wait \
	--debug
