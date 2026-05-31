%define _rpmfilename wallpapersearcher-%{version}-%{release}.x86_64.rpm

Name:       wallpapersearcher
Version:    @VERSION@
Release:    1
Summary:    Desktop wallpaper search app
License:    GPL-3.0-only
URL:        https://github.com/wallpapersearcher
BuildArch:  x86_64
BuildRoot:  %{_tmppath}/%{name}-buildroot
AutoReqProv: no

%description
Wallpaper Searcher is a desktop application for searching wallpapers
on Wallhaven with safe search enforced. Built with Rust + Qt 6 + cxx-qt.

%prep
# no-op: binary already built

%build
# no-op: binary already built

%install
rm -rf %{buildroot}
install -d -m 755 %{buildroot}%{_bindir}
install -m 755 %{_sourcedir}/wallpapersearcher %{buildroot}%{_bindir}/

%files
%{_bindir}/wallpapersearcher

%clean
rm -rf %{buildroot}
