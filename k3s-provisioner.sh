#/usr/bin/env bash
set -eu -o pipefail
chown root:root /etc/rancher/k3s/config.yaml
chmod 0644 /etc/rancher/k3s/config.yaml
chown root:root /etc/rancher/k3s/install.env
chmod 0600 /etc/rancher/k3s/install.env
set -o allexport
source /etc/rancher/k3s/install.env
set +o allexport
curl -fsL 'https://get.k3s.io' |  sh -s -  
