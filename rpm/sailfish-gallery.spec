Name:       sailfish-gallery

Summary:    Sailfish Gallery UI Components
Version:    0.0.1
Release:    1
Group:      System/Libraries
License:    TBD
URL:        https://bitbucket.org/jolla/ui-sailfish-gallery
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(QtCore) >= 4.8.0
BuildRequires:  pkgconfig(QtDeclarative)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtOpenGL)

Requires:  sailfishsilica >= 0.8.22
Requires:  nemo-qml-plugins-thumbnailer

%description
Sailfish Gallery UI Components

%prep
%setup -q -n %{name}-%{version}

%build

%qmake

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}

%qmake_install

#
# Sailfish Gallery files
#
%files
%defattr(-,root,root,-)
%{_libdir}/qt4/imports/Sailfish/Gallery/*

