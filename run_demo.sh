#! /usr/bin/bash

scenario=''
if [[ $1 = 'engine_and_hypervisor' || $1 = 'self_hosted' ]] ; then
  scenario=$1
  shift
fi
if [ -z "$scenario" ] ; then
  echo "Which scenario would you like to deploy?"
  echo "1. Self-hosted Engine"
  echo "2. Separate Engine and Hypervisors"
  read selection
  if [ $selection == '1' ] ; then
    scenario='self_hosted'
  elif [ $selection == '2' ] ; then
    scenario='engine_and_hypervisor'
  else
    echo "$selection is not a valid scenario choice"
    exit 1
  fi
fi

ansible-playbook demo/demo.yml --private-key=/usr/share/vagrant/keys/vagrant -i demo/$scenario -e @demo/$scenario.json -e "scenario=$scenario demo_dir=$(pwd)/demo ssh_key=$(cat /usr/share/vagrant/keys/vagrant.pub)" $@


echo "To retry launching the vms, just run:"
echo "ansible-playbook launch_vms.yml -e @demo/$scenario.json -i demo/$scenario --private-key=/usr/share/vagrant/keys/vagrant -e 'ssh_key=\$(cat /usr/share/vagrant/keys/vagrant.pub)'"
