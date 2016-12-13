Name:       ansible-ovirt
Version:    1.1.0
Release:    1%{?dist}
Summary:    Ansible module for installing and configuring Ovirt/RHV
Group:      Applications/System
License:    GPLv3+ and ASL 2.0
URL:        https://github.com/fusor/ansible-ovirt
Source0:    %{name}-%{version}.tar.gz

BuildArch:  noarch

Requires:  ansible >= 2.2

%description
Ansible module for installing and configuring Ovirt/RHV (engine + hypervisor or self-hosted scenarios)

%prep
%setup -q -n %{name}-%{version}
rm -rf ansible-ovirt.spec rel-eng

%build

%install
rm -rf %{buildroot}
install -d -m 0755 %{buildroot}/%{_datadir}/%{name}
cp -r * %{buildroot}/%{_datadir}/%{name}

%files
%{_datadir}/%{name}

%changelog
