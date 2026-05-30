Name:       wallpapersearcher
Version:    @VERSION@
Release:    1
Summary:    Desktop wallpaper search app
License:    MIT OR Apache-2.0
URL:        https://github.com/wallpapersearcher
Group:      User Interface/Desktops
BuildArch:  x86_64

%description
Wallpaper Searcher is a desktop application for searching wallpapers
on Wallhaven with safe search enforced. Built with Rust + Qt 6 + cxx-qt.

%install
install -m 755 -d %{buildroot}%{_bindir}
install -m 755 %{_builddir}/%{name}-%{version}-1.x86_64/usr/bin/wallpapersearcher %{buildroot}%{_bindir}/

%files
%{_bindir}/wallpapersearcher

%changelog
* 2026-05-30  Wallpaper Searcher Team  @VERSION@-1
- Initial release
