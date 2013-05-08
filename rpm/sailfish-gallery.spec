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

%package tests
Summary:    Unit tests for Sailfish Gallery UI components
Group:      System/Libraries
BuildRequires:  pkgconfig(QtTest)
Requires:   %{name} = %{version}-%{release}
Requires:   qtest-qml

%description tests
This package contains QML unit tests for Sailfish Gallery UI components

%prep
%setup -q -n %{name}-%{version}

%build

%qmake

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}

# Copy tests
mkdir -p %{buildroot}/opt/tests/sailfish-gallery/test-definition
mkdir -p %{buildroot}/opt/tests/sailfish-gallery/auto
cp -a tests/test-definition/tests.xml %{buildroot}/opt/tests/sailfish-gallery/test-definition
cp -a tests/auto/*qml %{buildroot}/opt/tests/sailfish-gallery/auto
cp -a tests/auto/*js %{buildroot}/opt/tests/sailfish-gallery/auto

%qmake_install

#
# Sailfish Gallery files
#
%files
%defattr(-,root,root,-)
%{_libdir}/qt4/imports/Sailfish/Gallery/*

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/sailfish-gallery/*
# << files tests

