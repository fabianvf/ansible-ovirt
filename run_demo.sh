#! /usr/bin/bash

scenario=$1
if [ -z "$scenario" ] ; then
  echo "Which scenario would you like to deploy?"
  echo "1. Self-hosted Engine"
  echo "2. Separate Engine and Hypervisors"
  read selection
  if [ $selection == '1' ] ; then
    scenario='self_hosted'
  elif [ $selection == '2' ] ; then
    scenario='engine_and_hypervisor'
  fi
fi
if  ! [ $scenario == 'self_hosted' ]  && ! [ $scenario == 'engine_and_hypervisor' ] ; then
  echo "$scenario is not a valid scenario"
  exit 1
fi

(set -x
cd demo

# export VAGRANT_LOG='debug'
vagrant destroy
sudo virsh net-destroy demo0
sudo virsh net-undefine demo0
vagrant up &&(

sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:41' name='x1.example.org' ip='192.168.33.11' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:42' name='x2.example.org 'ip='192.168.33.12' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:43' name='x3.example.org 'ip='192.168.33.13' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:44' name='nfs.example.org' ip='192.168.33.14' />" --live --config
sudo virsh net-update demo0 add ip-dhcp-host "<host mac='52:11:22:33:44:45' name='ovirt-engine.example.org' ip='192.168.33.15' />" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.11' ><hostname>x1.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.12' ><hostname>x2.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.13' ><hostname>x3.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.14' ><hostname>nfs.example.org</hostname></host>" --live --config
sudo virsh net-update demo0 add dns-host "<host ip='192.168.33.15' ><hostname>ovirt-engine.example.org</hostname></host>" --live --config)
) &&  ansible-playbook $scenario.yml -e @demo/$scenario.json -i demo/$scenario --private-key=/usr/share/vagrant/keys/vagrant
