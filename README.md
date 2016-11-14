Ansible module for installing and configuring Ovirt/RHV (engine + hypervisor or self-hosted scenarios)

Requires ansible >= 2.1

# Testing Vagrant environment
Requires the `vagrant-libvirt` and `vagrant-hostmanager` plugins

Optionally uses the `vagrant-cachier` plugin, to cache packages between `vagrant up`s (strongly recommend for testing self-hosted, which downloads ~2GB of packages per deployment)

The easiest way to use the vagrant environment is to run the provided `run_demo.sh` script. It will give you the option to deploy either the self-hosted or engine and hypervisor scenarios, and handle bringing up and configuring the virtual machines and networking, as well as running the ansible scripts. If you would rather deploy it by hand, you can follow the steps below.

1. `cd demo`

1. `vagrant up`

    This will bring up 4 VMs
    - {x1|x2|x3}.example.org, each with 8GB of memory using all available processors
    - nfs.example.org, with 2GB memory and 1 CPU
    
    If you don't have enough resource to run all of them, you can specify the specific vms to bring up (the nfs VM will always be required):
    
    `vagrant up x1 nfs`

1. `cd ..`

1. The following commands will configure DNS and DHCP on the virtual network named demo0, which should have been created by vagrant. 
```
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:41' name='x1.example.org' ip='192.168.33.11' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:42' name='x2.example.org 'ip='192.168.33.12' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:43' name='x3.example.org 'ip='192.168.33.13' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:44' name='nfs.example.org' ip='192.168.33.14' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:45' name='ovirt-engine.example.org' ip='192.168.33.15' />" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.11' ><hostname>x1.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.12' ><hostname>x2.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.13' ><hostname>x3.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.14' ><hostname>nfs.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.15' ><hostname>ovirt-engine.example.org</hostname></host>" --live --config
```

1. (a) To deploy self-hosted ovirt:

    `ansible-playbook -i demo/self_hosted self_hosted.yml -e "@demo/self_hosted.json" --private-key=/usr/share/vagrant/keys/vagrant`

   (b) To deploy ovirt with separate engine + hypervisors:

    `ansible-playbook -i demo/engine_and_hypervisor engine_and_hypervisor.yml -e "@demo/engine_and_hypervisor.json" --private-key=/usr/share/vagrant/keys/vagrant`
    
    *Note* If you did not bring up all of the VMs when you ran vagrant up, you will need to explicitly exclude the hosts that are down from the playbook run. You can do this by appending `--limit '!x2.example.org:!x3.example.org'` to the above commands, replacing x1/x2.example.org with the hosts that are down.
