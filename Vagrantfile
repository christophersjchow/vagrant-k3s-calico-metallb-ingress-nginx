# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] ||= 'parallels'

Vagrant.configure("2") do |config|
  %w[vmware_desktop parallels].each do |p|
    config.vm.provider p do |v|
      v.cpus = ENV['CPUS'] || 2         # k3s behaves much better with 2 cpu
      v.memory = ENV['MEMORY'] || 2048  # the memory helps dnf/yum evade the oom-killer sans swap
    end
  end

  master_ip_address = '192.168.3.51'
  node_1_name = "vagrant-k3s-1"

  config.vm.define node_1_name, primary: true do |node|
    node.vm.box = 'bento/ubuntu-22.04-arm64'
    node.vm.hostname = node_1_name
    node.vm.network :public_network, ip: master_ip_address, bridge: 'en12'

    node.vm.provision :shell, path: 'install-packages.sh'
    node.vm.provision :k3s do |k3s|
      k3s.env = [
        'INSTALL_K3S_CHANNEL=stable',
        'INSTALL_K3S_NAME=server',
        'K3S_KUBECONFIG_MODE=0644',
        'K3S_TOKEN=vagrant-k3s',
        "K3S_NODE_NAME=#{node_1_name}",
      ]
      k3s.skip_start = false
      k3s.config = {
        :disable => %w[local-storage servicelb traefik],
        'disable-network-policy' => true,
        'flannel-backend' => 'none',
      }
      k3s.config_mode = '0644' # side-step https://github.com/k3s-io/k3s/issues/4321
    end
  end

  (2..3).each do |i|
    node_name = "vagrant-k3s-#{i}"

    config.vm.define node_name do |node|
      ip_address = "192.168.3.5#{i}"

      node.vm.box = 'bento/ubuntu-22.04-arm64'
      node.vm.hostname = node_name
      node.vm.network :public_network, ip: ip_address, bridge: 'en12'

      node.vm.provision :shell, path: 'install-packages.sh'
      node.vm.provision :k3s, run: "once" do |k3s|
        k3s.env = [
          'INSTALL_K3S_CHANNEL=stable',
          'INSTALL_K3S_NAME=agent',
          'K3S_KUBECONFIG_MODE=0644',
          'K3S_TOKEN=vagrant-k3s',
          "K3S_URL=https://#{master_ip_address}:6443",
          "K3S_NODE_NAME=#{node_name}",
        ]
        k3s.skip_start = false
        k3s.args = %w[agent]
        k3s.config_mode = '0644' # side-step https://github.com/k3s-io/k3s/issues/4321
      end
    end
  end
end
